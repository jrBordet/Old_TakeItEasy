//
//  StationViewController.swift
//  ViaggioTreno
//
//  Created by Jean Raphael on 17/11/2017.
//  Copyright © 2017 Jean Raphael. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SwiftSpinner

enum Update: Int {
    case departure
    case arrivals
}

protocol ListTrainsCoordinator {
    func showTravelDetail(of travel: Travel)
}

class ListTrainsViewController: UIViewController {
    @IBOutlet weak var departuresTableView: UITableView!
    
    final var station: Station?
    
    private var trainsVariable = Variable<[Travel?]>([nil])
    lazy var trainsObservable: Observable<[Travel?]> = trainsVariable.asObservable()
    
    private let bag = DisposeBag()
    
    final var coordinatorDelegate: ListTrainsCoordinator?
    
    private let loadingMessage = "Loading"
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Partenze"

        // Table view
        _ = departuresTableView
            .rx
            .setDelegate(self)
        
        performUpdate(of: .departure)
        
        bindUI()
    }
    
    // MARK: - Actions
    
    @IBAction func refreshAction(_ sender: Any) {
        SwiftSpinner.show(loadingMessage)
        
        performUpdate(of: .departure)
    }
    
    @IBAction func performDeparturesUpdate(_ sender: Any) {
        title = "Partenze"
        
        performUpdate(of: .departure)
    }
    
    @IBAction func performArrivalsUpdate(_ sender: Any) {
        title = "Arrivi"
        
        performUpdate(of: .arrivals)
    }
    
    // MARK: - Privates
    
    private func bindUI() {
        trainsObservable
            .bind(to:
                departuresTableView
                    .rx
                    .items(cellIdentifier: "DepartureCell", cellType: TrainCell.self)) { index, model, cell in
                        cell.backgroundColor = UIColor.black
                        cell.destinationLabel?.textColor = UIColor.white
                        cell.stateLabel?.textColor = UIColor.white
                        
                        if let train = model {
                            cell.destinationLabel?.text = train.direction.capitalizingFirstLetter()
                            cell.stateLabel?.text = train.state
                            
                            cell.numberLabel?.text = String(describing: train.number)
                            cell.hourLabel?.text = train.time
                        }
            }
            .disposed(by: bag)
        
        // MARK: - Selected
        
        departuresTableView
            .rx
            .modelSelected(Travel.self)
            .subscribe(onNext: { [weak self] travel in
                if let coordinator = self?.coordinatorDelegate {
                    coordinator.showTravelDetail(of: travel)
                }
            })
            .disposed(by: bag)
    }
    
    private func performUpdate(of index: Update) {
        SwiftSpinner.show(loadingMessage)
        
        guard let station = station else { return }
        
        switch index {
        case .departure:
            TravelTrainAPI.trainDepartures(of: station.id).map({ [weak self] departures -> Bool in
                self?.trainsVariable.value = departures
                
                return false
            }).bind(to: SwiftSpinner.sharedInstance.rx_visible)
                .disposed(by: bag)
            return
            
        case .arrivals:
            TravelTrainAPI.trainArrivals(of: station.id).map({ [weak self] departures -> Bool in
                self?.trainsVariable.value = departures
                
                return false
            }).bind(to: SwiftSpinner.sharedInstance.rx_visible)
                .disposed(by: bag)
            return
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

// MARK: - UITableViewDelegate

extension ListTrainsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
}
