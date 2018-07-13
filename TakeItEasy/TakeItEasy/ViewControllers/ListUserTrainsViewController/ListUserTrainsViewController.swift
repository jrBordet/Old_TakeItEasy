//
//  ListUserTrainsViewController.swift
//  TakeItEasy
//
//  Created by Jean Raphael on 04/03/2018.
//  Copyright © 2018 Jean Raphael Bordet. All rights reserved.
//

import UIKit
import CoreData
import RxSwift
import RxCocoa
import RxDataSources
import RxCoreData

protocol ListUserTrainsCoordinator {
    func showStations()
    
    func showTravelDetail(of travel: Travel)
}

class ListUserTrainsViewController: UIViewController {
    @IBOutlet weak var trainTableView: UITableView!
    @IBOutlet var disclaimerView: UIView!
    @IBOutlet var disclaimerLabel: UILabel! {
        didSet {
            disclaimerLabel.text = NSLocalizedString("ci dispiace...", comment: "")
        }
    }
    
    typealias DataSourceModel = Travel
    
    final var coordinatorDelegate: ListUserTrainsCoordinator?
    
    var managedObjectContext: NSManagedObjectContext!
    
    private let bag = DisposeBag()
    
    // MARK: - Lif cycle
    
    override func viewDidLoad() {
        bindUI()
    }
    
    // MARK: - Actions
    
    @IBAction func stationsTap(_ sender: Any) {
        guard let coordinator = coordinatorDelegate else { return }
                
        coordinator.showStations()
    }
    
    // MARK: - Privates
    
    private func bindUI() {
        trainTableView.rowHeight = 75
        
        let animatedDataSource = RxTableViewSectionedReloadDataSource<AnimatableSectionModel<String, DataSourceModel>>(configureCell: { dateSource, tableView, indexPath, travel in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TravelCell", for: indexPath) as? UserTrainCell else { return UITableViewCell(style: .default, reuseIdentifier: nil) }
            
            cell.departureLabel.text = "\(travel.originStation?.capitalizingFirstLetter() ?? "")"
            cell.arrivalLabel.text = "\(travel.direction.capitalizingFirstLetter())"
            cell.timeLabel.text = "\(travel.time)"
            cell.kindLabel.text = "\(travel.category.capitalizingFirstLetter()) \(travel.number)"
            
            cell.backgroundColor = .primayBlack
            
            return cell
        })
        
        managedObjectContext
            .rx
            .entities(DataSourceModel.self, sortDescriptors: nil)
            .map { travels in
                if travels.count != 0 {
                    self.trainTableView.isHidden = false
                    self.disclaimerView.isHidden = true
                } else {
                    self.trainTableView.isHidden = true
                    self.disclaimerView.isHidden = false
                }
                
                return [AnimatableSectionModel(model: "", items: travels)]
            }
            .bind(to: trainTableView.rx.items(dataSource: animatedDataSource))
            .disposed(by: bag)
        
        // MARK: - item deleted
        
        trainTableView
            .rx
            .itemDeleted
            .map { [unowned self] ip -> DataSourceModel in
                return try self.trainTableView.rx.model(at: ip)
            }.subscribe(onNext: { [unowned self] (event) in
                do {
                    try
                        self.managedObjectContext
                        .rx
                        .delete(event)
                } catch {
                    print(error)
                }
            }).disposed(by: bag)
        
        animatedDataSource.canEditRowAtIndexPath = { _,_  in
            return true
        }
        
        animatedDataSource.canMoveRowAtIndexPath = { _,_  in
            return true
        }
        
        // MARK: - modelSelected
        
        trainTableView
            .rx
            .modelSelected(DataSourceModel.self)
            .subscribe(onNext: { [weak self] travel in
            guard let coordinator = self?.coordinatorDelegate else { return }
            
            coordinator.showTravelDetail(of: travel)
        }).disposed(by: bag)
    }
}
