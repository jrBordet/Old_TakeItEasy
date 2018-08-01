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
import DatePickerDialog

protocol ListTrainsCoordinator {
    func showTravelDetail(of travel: Travel)
}

class ListTrainsViewController: UIViewController {
    @IBOutlet weak var trainTableView: UITableView!
    @IBOutlet var refreshButton: UIBarButtonItem!
    
    // MARK: - Dependencies
    
    var viewModel: UserTrainViewModel!
    
    private let bag = DisposeBag()
    
    // MARK: - Coordinator
    
    final var coordinatorDelegate: ListTrainsCoordinator?
    
    // MARK: - Privates
    
    final var status: Update = .departure
    
    var currentDate = Date()
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if DEBUG
        let logString = "⚠️ Number of start resources = \(Resources.total) ⚠️"
        debugPrint(logString)
        #endif
        
        currentDate = Date()
        
        title = NSLocalizedString("Partenze", comment: "Partenze")
        
        bindUI()
    }
    
    deinit {
        debugPrint("\(self) deinit")
    }
    
    // MARK: - Actions
    
    @IBAction func refreshAction(_ sender: Any) {
        performUpdate()
    }
    
    @IBAction func switchAction(_ sender: Any) {
        status.toogle()
        
        performUpdate()
    }
    
    @IBAction func scheduletap(_ sender: Any) {
        let dialog = DatePickerDialog(textColor: .black,
                                      buttonColor: .black,
                                      font: UIFont(name: "HelveticaNeue-Medium", size: 17)!,
                                      locale: Locale(identifier: "it_IT"),
                                      showCancelButton: true)
        
        dialog.show("", doneButtonTitle: "Conferma", cancelButtonTitle: "Annulla", minimumDate: Date()) { date -> Void in
            if let date = date {
                self.currentDate = date
                
                self.performUpdate()
            }
        }
    }
    
    // MARK: - Privates
    
    private func bindUI() {
        trainTableView.rowHeight = 64
        
        SwiftSpinner.show(NSLocalizedString("Loading", comment: "Loading"))

        // MARK: - ViewModel binding
        
        // Table view
        viewModel
            .fetchTravels
            .elements
            .bind(to: trainTableView.rx.items(cellIdentifier: "DepartureCell", cellType: TrainCell.self)) { index, model, cell in
                cell.destinationLabel?.textColor = UIColor.white
                cell.stateLabel?.textColor = UIColor.white
                
                if let train = model {
                    if let direction = train.direction {
                        cell.destinationLabel?.text = direction.capitalizingFirstLetter()
                    } else if let origin = train.originStation {
                        cell.destinationLabel?.text = origin.capitalizingFirstLetter()
                    }
                    
                    cell.stateLabel?.text = train.state
                    
                    cell.numberLabel?.text = String(describing: train.number)
                    cell.hourLabel?.text = train.time
                }
                
                cell.backgroundColor = .primayBlack
            }
            .disposed(by: bag)
        
        // Spinner
        viewModel
            .fetchTravels
            .executing
            .bind(to: SwiftSpinner.sharedInstance.rx_visible)
            .disposed(by: bag)
        
        // Execution
        viewModel
            .fetchTravels
            .execute((direction: .departure, date: Date()))
        
        // MARK: - modelSelected (saving operations)
        
        trainTableView
            .rx
            .modelSelected(Travel.self)
            .map { [weak self] travel -> Travel in
                return Travel(travel.number,
                              originCode: travel.originCode,
                              category: travel.category,
                              time: travel.time,
                              direction: travel.direction != nil ? travel.direction : self?.viewModel.stationName ?? nil,
                              state: travel.state,
                              originStation: travel.originStation != nil ? travel.originStation : self?.viewModel.stationName ?? nil)
            }
            .subscribe(onNext: { [weak self] travel in
                guard let coordinator = self?.coordinatorDelegate else { return }
                
                self?.viewModel.save(travel: travel)
                
                coordinator.showTravelDetail(of: travel)
            })
            .disposed(by: bag)
    }
    
    private func performUpdate() {
        SwiftSpinner.show(NSLocalizedString("Loading", comment: "Loading"))

        switch status {
        case .departure:
            title = NSLocalizedString("Partenze", comment: "Partenze")

            viewModel
                .fetchTravels
                .execute((direction: .departure, date: currentDate))
            
        case .arrivals:
            title = NSLocalizedString("Arrivi", comment: "Arrivi")
            
            viewModel
                .fetchTravels
                .execute((direction: .arrivals, date: currentDate))
        }
    }
    
}

