//
//  ListUserStation.swift
//  ViaggioTreno
//
//  Created by Jean Raphael on 02/12/2017.
//  Copyright © 2017 Jean Raphael. All rights reserved.
//

import UIKit
import CoreData
import RxSwift
import RxCocoa
import RxDataSources
import RxCoreData

protocol ListUserStationCoordinator {
    func showTrainSpootlight()
    
    func showTrains()
    
    func showDepartures(of station: Station)
}

class ListUserStationViewController: UIViewController {
    @IBOutlet weak var userStationsTableView: UITableView!
    
    typealias DataSourceModel = Station
    
    var managedObjectContext: NSManagedObjectContext!
    
    final var coordinatorDelegate: ListUserStationCoordinator?
    
    private let bag = DisposeBag()
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindUserStationsUI()
    }
    
    // MARK: - Actions
    
    @IBAction func spotlightTap(_ sender: Any) {
        guard let coordinator = coordinatorDelegate else { return }
        
        coordinator.showTrainSpootlight()
    }
    
    @IBAction func trainsTap(_ sender: Any) {
        guard let coordinator = coordinatorDelegate else { return }
        
        coordinator.showTrains()
    }
    
    // MARK: - Privates
    
    private func bindUserStationsUI() {
        let animatedDataSource = RxTableViewSectionedReloadDataSource<AnimatableSectionModel<String, DataSourceModel>>(configureCell: { dateSource, tableView, indexPath, station in
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserStationCell", for: indexPath)
            
            cell.textLabel?.text = "\(station.name)".capitalizingFirstLetter()
            
            return cell
        })
                
        managedObjectContext
            .rx
            .entities(DataSourceModel.self, sortDescriptors: nil)
            .map { stations in
                return [AnimatableSectionModel(model: "", items: stations)]
            }
            .bind(to: userStationsTableView.rx.items(dataSource: animatedDataSource))
            .disposed(by: bag)
        
        // MARK: - item deleted
        
        userStationsTableView
            .rx
            .itemDeleted
            .map { [unowned self] ip -> DataSourceModel in
                return try self.userStationsTableView.rx.model(at: ip)
            }
            .subscribe(onNext: { [unowned self] (event) in
                do {
                    try self.managedObjectContext.rx.delete(event)
                } catch {
                    print(error)
                }
            })
            .disposed(by: bag)
        
        animatedDataSource.canEditRowAtIndexPath = { _,_  in
            return true
        }
        
        animatedDataSource.canMoveRowAtIndexPath = { _,_  in
            return true
        }
        
        // MARK: - modelSelected
        
        userStationsTableView
            .rx
            .modelSelected(DataSourceModel.self)
            .subscribe(onNext: { [weak self] station in
                guard let coordinator = self?.coordinatorDelegate else { return }
                
                coordinator.showDepartures(of: station)
            }).disposed(by: bag)
    }
    
}
