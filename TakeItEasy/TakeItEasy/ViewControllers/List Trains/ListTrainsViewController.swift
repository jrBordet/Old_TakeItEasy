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
import CoreData
import RxCoreData

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
    @IBOutlet weak var trainTableView: UITableView!
    
    var managedObjectContext: NSManagedObjectContext!
    
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
        
//        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

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
        
        trainsObservable.bind(to: trainTableView.rx.items(cellIdentifier: "DepartureCell", cellType: TrainCell.self)) { index, model, cell in
            cell.destinationLabel?.textColor = UIColor.white
            cell.stateLabel?.textColor = UIColor.white
            
            if let train = model {
                cell.destinationLabel?.text = train.direction.capitalizingFirstLetter()
                cell.stateLabel?.text = train.state
                
                cell.numberLabel?.text = String(describing: train.number)
                cell.hourLabel?.text = train.time
            }
            
            cell.backgroundColor = .primayBlack
        }.disposed(by: bag)
        
        // MARK: - modelSelected

        trainTableView.rx.modelSelected(Travel.self).subscribe(onNext: { [weak self] travel in
            guard let coordinator = self?.coordinatorDelegate else { return }
            
            self?.save(travel: travel)
            
            coordinator.showTravelDetail(of: travel)
        }).disposed(by: bag)
    }

    private func performUpdate() {
        guard let station = station else { return }

        SwiftSpinner.show(loadingMessage)
        
        switch status {
        case .departure:
            TravelTrainAPI
                .trainDepartures(of: station.id, date: currentDate)
                .map({ [weak self] results -> Bool in
                    self?.trainsVariable.value = results
                    
                    DispatchQueue.main.async(execute: {
                        self?.trainTableView.isHidden = results.count == 0 ? true : false
                        self?.title =  results.count == 0 ? "" : "Partenze"
                    })
                    
                    return false
                })
                .bind(to: SwiftSpinner.sharedInstance.rx_visible)
                .disposed(by: bag)
            
        case .arrivals:
            title = String(format: "Arrivi")

            TravelTrainAPI
                .trainArrivals(of: station.id, date: currentDate)
                .map({ [weak self] results -> Bool in
                    self?.trainsVariable.value = results
                    
                    DispatchQueue.main.async(execute: {
                        self?.trainTableView.isHidden = results.count == 0 ? true : false
                        self?.title =  results.count == 0 ? "" : "Arrivi"
                    })
                    
                    return false
                })
                .bind(to: SwiftSpinner.sharedInstance.rx_visible)
                .disposed(by: bag)
        }
    }
    
    private final func save(travel t: Travel) {
        guard let mc = managedObjectContext, let station = station else { return }
        
        let result = Travel.init(t.number,
                                 originCode: t.originCode,
                                 category: t.category,
                                 time: t.time,
                                 direction: t.direction,
                                 state: t.state,
                                 originStation: station.name)
        do {
            try mc.rx.update(result)
        } catch {
            fatalError("\(String(describing: self)) fail on update \(t)")
        }
    }
    
}

