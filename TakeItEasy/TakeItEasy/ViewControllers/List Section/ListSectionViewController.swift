//
//  ListSessionViewController.swift
//  TakeItEasy
//
//  Created by Jean Raphael on 19/01/2018.
//  Copyright © 2018 Jean Raphael Bordet. All rights reserved.
//

import UIKit
import CoreData
import RxCoreData
import RxSwift
import RxCocoa
import RxDataSources
import SwiftSpinner

protocol ListSectionCoordinator {
    func showTrainSections(of departureCode: String, trainCode: String)
}

class ListSectionViewController: UIViewController {
    @IBOutlet var sessionTableView: UITableView!
    
    private var sessionVariable = Variable<[Section?]>([nil])
    lazy var sessionObservable: Observable<[Section?]> = sessionVariable.asObservable()
    
    final var coordinatorDelegate: ListSectionCoordinator?
    
    final var travel: Travel?
    
    private let bag = DisposeBag()
    
    var managedObjectContext: NSManagedObjectContext!
    
    private let loadingMessage = "Loading"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let travel = travel else { return }
        
        // Table view
        _ = sessionTableView.rx.setDelegate(self)
        
        bindUI()
        
        title = travel.direction
        
        SwiftSpinner.show(loadingMessage)
        
        performUpdate(of: travel.originCode, travelNumber: String(travel.number))
    }
    
    // MARK: - Actions
    
    @IBAction func refreshAction(_ sender: Any) {
        guard let travel = travel else { return }
        
        SwiftSpinner.show(loadingMessage)
        
        performUpdate(of: travel.originCode, travelNumber: String(travel.number))
    }
    
    // MARK: - Privates
    
    private func performUpdate(of originCode: String, travelNumber: String) {
        TravelTrainAPI
            .trainSections(of: originCode, travelNumber)
            .map ({ [weak self] section -> Bool in
                self?.sessionVariable.value = section
                
                return false
            })
            .bind(to: SwiftSpinner.sharedInstance.rx_visible)
            .disposed(by: bag)
    }
    
    private func bindUI() {
        sessionObservable
            .bind(to: sessionTableView
                .rx
                .items(cellIdentifier: "SectionCell", cellType: SectionCell.self)) { index, model, cell in
                    guard let model = model else { return }
                    
                    cell.stationLabel.text = model.station.capitalized
                    cell.hourlabel.text = model.departure != 0 ? model.departureHour : model.arrivalHour
                    
                    cell.backgroundColor = .primayBlack
                    
                    cell.hourlabel.textColor = model.current ? .green : .lightGray
            }
            .disposed(by: bag)
    }
}

// MARK: - UITableViewDelegate

extension ListSectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
}
