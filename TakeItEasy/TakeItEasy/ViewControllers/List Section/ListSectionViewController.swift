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
    @IBOutlet var trainStatusLabel: UILabel!
    @IBOutlet var trainNumber: UILabel!
    
    // MARK: - Coordinator
    
    final var coordinatorDelegate: ListSectionCoordinator?
    
    // MARK: - Privates
    
    private let bag = DisposeBag()
    
    // MARK: - Dependencies
    
    var viewModel: SectionViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - Table view delegate
        _ = sessionTableView
            .rx
            .setDelegate(self)
        
        bindUI()
    }
    
    // MARK: - Actions
    
    @IBAction func refreshAction(_ sender: Any) {
        SwiftSpinner.show(NSLocalizedString("Loading", comment: "Loading"))
        
        viewModel
            .fetchSection
            .execute(true)
    }
    
    // MARK: - Privates
    
    private func bindUI() {
        
        SwiftSpinner.show(NSLocalizedString("Loading", comment: "Loading"))
        
        // MARK: - ViewModel binding
        
        viewModel
            .trainStatus
            .drive(trainStatusLabel.rx.text)
            .disposed(by: bag)
        
        viewModel
            .trainNumber
            .drive(trainNumber.rx.text)
            .disposed(by: bag)
        
        viewModel
            .fetchSection
            .elements
            .bind(to: sessionTableView
                .rx
                .items(cellIdentifier: "SectionCell", cellType: SectionCell.self)) { index, model, cell in
                    guard let model = model else { return }
                    
                    cell.stationLabel.text = model.station.capitalized
                    cell.hourlabel.text = model.departure != 0 ? model.departureHour : model.arrivalHour
                    
                    cell.backgroundColor = .primayBlack
                    
                    cell.hourlabel.textColor = model.current ? .green : .lightGray
                    cell.railLabel.textColor = model.current ? .green : .lightGray
                    cell.isSelected = model.current
                    
                    cell.railLabel.text = model.binarioEffettivoPartenzaDescrizione != "" ? model.binarioEffettivoPartenzaDescrizione : model.binarioEffettivoPartenzaDescrizione
                    
                    debugPrint("\(model.binarioEffettivoPartenzaDescrizione ) \(model.binarioEffettivoPartenzaDescrizione)")
            }
            .disposed(by: bag)
        
        // Spinner
        viewModel
            .fetchSection
            .executing
            .bind(to: SwiftSpinner.sharedInstance.rx_visible)
            .disposed(by: bag)
        
        // Execution
        viewModel
            .fetchSection
            .execute(true)
    }
}

// MARK: - UITableViewDelegate

extension ListSectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
}
