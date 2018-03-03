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

enum Update: Int {
    case departure
    case arrivals
    
    mutating func toogle() {
        switch self {
        case .departure:
            self = .arrivals
        case .arrivals:
            self = .departure
        }
    }
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
    
    final var status: Update = .departure
    
    var currentDate = Date()
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = departuresTableView.rx.setDelegate(self)
        
        currentDate = Date()
        
        performUpdate()
        
        bindUI()
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
        
        dialog.show("", doneButtonTitle: "Conferma", cancelButtonTitle: "Annulla", minimumDate: Date(), datePickerMode: .dateAndTime) { date -> Void in
            if let date = date {
                self.currentDate = date
                
                self.performUpdate()
            }
        }
    }
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        let componenets = Calendar.current.dateComponents([.year, .month, .day], from: sender.date)
        if let day = componenets.day, let month = componenets.month, let year = componenets.year {
            print("\(day) \(month) \(year)")
        }
    }
    
    // MARK: - Privates
    
    private func bindUI() {
        trainsObservable.bind(to: departuresTableView.rx.items(cellIdentifier: "DepartureCell", cellType: TrainCell.self)) { index, model, cell in
            cell.backgroundColor = UIColor.black
            cell.destinationLabel?.textColor = UIColor.white
            cell.stateLabel?.textColor = UIColor.white
            
            if let train = model {
                cell.destinationLabel?.text = train.direction.capitalizingFirstLetter()
                cell.stateLabel?.text = train.state
                
                cell.numberLabel?.text = String(describing: train.number)
                cell.hourLabel?.text = train.time
            }
        }.disposed(by: bag)
        
        // MARK: - Selected
        
        departuresTableView.rx.modelSelected(Travel.self).subscribe(onNext: { [weak self] travel in
                if let coordinator = self?.coordinatorDelegate {
                    coordinator.showTravelDetail(of: travel)
                }
            }).disposed(by: bag)
    }

    private func performUpdate() {
        guard let station = station else { return }

        SwiftSpinner.show(loadingMessage)
        
        switch status {
        case .departure:
            title = "Partenze"
            
            TravelTrainAPI.trainDepartures(of: station.id, date: currentDate).map({ [weak self] departures -> Bool in
                self?.trainsVariable.value = departures
                
                return false
            }).bind(to: SwiftSpinner.sharedInstance.rx_visible).disposed(by: bag)
            
        case .arrivals:
            title = "Arrivi"
            
            TravelTrainAPI.trainArrivals(of: station.id, date: currentDate).map({ [weak self] departures -> Bool in
                self?.trainsVariable.value = departures
                
                return false
            }).bind(to: SwiftSpinner.sharedInstance.rx_visible).disposed(by: bag)
        }
    }
    
    
}

// MARK: - UITableViewDelegate

extension ListTrainsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
}

