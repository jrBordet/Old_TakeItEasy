//
//  ListUserTrainsViewController.swift
//  TakeItEasy
//
//  Created by Jean Raphael on 04/03/2018.
//  Copyright © 2018 Jean Raphael Bordet. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources

import SwiftSpinner

protocol ListUserTrainsCoordinator: class {
    func showStations()
    
    func showTravelDetail(of travel: Travel)
}

class ListUserTrainsViewController: UIViewController {
    @IBOutlet weak var trainTableView: UITableView!
    @IBOutlet var disclaimerView: UIView!
    @IBOutlet var disclaimerLabel: UILabel! {
        didSet {
            disclaimerLabel.text = NSLocalizedString("ci dispiace …", comment: "")
        }
    }
    
    typealias DataSourceModel = Travel
    private let bag = DisposeBag()

    // MARK: - Delegate
    
    var coordinatorDelegate: ListUserTrainsCoordinator?
    
    // MARK: - Dependencies
    
    var viewModel: UserTrainViewModel!
    
    // MARK: - Lif cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        #if DEBUG
        let logString = "⚠️ Number of start resources = \(Resources.total) ⚠️"
        debugPrint(logString)
        #endif

        bindUI()
    }
    
    deinit {
        debugPrint("\(self) deinit")
    }
    
    // MARK: - Actions
    
    @IBAction func stationsTap(_ sender: Any) {
        guard let coordinator = coordinatorDelegate else { return }
                
        coordinator.showStations()
    }
    
    // MARK: - Privates
    
    private func bindUI() {
        trainTableView.rowHeight = 75
        
        // MARK: - RxDataSource
        
        let animatedDataSource = RxTableViewSectionedReloadDataSource<AnimatableSectionModel<String, DataSourceModel>>(configureCell: { dateSource, tableView, indexPath, travel in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TravelCell", for: indexPath) as? UserTrainCell else { return UITableViewCell(style: .default, reuseIdentifier: nil) }
            
            cell.departureLabel.text = "\(travel.originStation?.capitalizingFirstLetter() ?? "")"
            cell.arrivalLabel.text = "\(travel.direction?.capitalizingFirstLetter() ?? "")"
            
            cell.timeLabel.text = "\(travel.time)"
            cell.kindLabel.text = "\(travel.category.capitalizingFirstLetter()) \(travel.number)"
            
            cell.backgroundColor = .primayBlack
            
            return cell
        })
        
        // MARK: - ViewModel binding
        
        viewModel
            .travelItems
            .map { travel in
                if travel.count != 0 {
                    self.trainTableView.isHidden = false
                    self.disclaimerView.isHidden = true
                } else {
                    self.trainTableView.isHidden = true
                    self.disclaimerView.isHidden = false
                }
                
                return [AnimatableSectionModel(model: "", items: travel)]
            }
            .bind(to: trainTableView.rx.items(dataSource: animatedDataSource))
            .disposed(by: bag)
        
        // MARK: - item deleted
        
        trainTableView
            .rx
            .itemDeleted
            .map { [unowned self] ip -> DataSourceModel in
                return try self.trainTableView.rx.model(at: ip)
            }.subscribe(onNext: { [unowned self] (model) in
                self.viewModel.delete(model: model)
            })
            .disposed(by: bag)
        
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
        })
        .disposed(by: bag)
    }
}
