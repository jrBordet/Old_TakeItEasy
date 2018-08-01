//
//  ListSessionViewController.swift
//  TakeItEasy
//
//  Created by Jean Raphael on 19/01/2018.
//  Copyright © 2018 Jean Raphael Bordet. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SwiftSpinner

protocol ListSectionCoordinator {
    func showTrainSections(of departureCode: String, trainCode: String)
}

class ListSectionViewController: UIViewController {
    @IBOutlet var sessionTableView: UITableView!
    
    // MARK: - Coordinator
    
    final var coordinatorDelegate: ListSectionCoordinator?
    
    // MARK: - Privates
    
    private let bag = DisposeBag()
    
    // MARK: - Dependencies
    
    var viewModel: SectionViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if DEBUG
        let logString = "⚠️ Number of start resources = \(Resources.total) ⚠️"
        debugPrint(logString)
        #endif
        
        sessionTableView.estimatedRowHeight = 64
        sessionTableView.rowHeight = 64
        
        sessionTableView
            .rx
            .setDelegate(self)
            .disposed(by: bag)
        
        bindUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    deinit {
        debugPrint("\(self) deinit")
    }
    
    // MARK: - Actions
    
    @IBAction func refreshAction(_ sender: Any) {
        SwiftSpinner.show(NSLocalizedString("Loading", comment: "Loading"))
        
        viewModel
            .fetchSectionResult
            .execute(true)
    }
    
    // MARK: - Privates
    
    private func bindUI() {
        
        SwiftSpinner.show(NSLocalizedString("Loading", comment: "Loading"))
        
        // MARK: - ViewModel binding
        
        viewModel
            .fetchSectionResult
            .elements
            .bind(to: sessionTableView.rx.items(cellIdentifier: "SectionCell", cellType: SectionCell.self)) { [weak self] index, model, cell in
                Observable<SectionResult>
                    .just(model)
                    .bind(to: cell.rx.sectionResult)
                    .disposed(by: (self?.bag)!)
            }
            .disposed(by: bag)
        
        // Spinner
        viewModel
            .fetchSectionResult
            .executing
            .bind(to: SwiftSpinner.sharedInstance.rx_visible)
            .disposed(by: bag)
        
        // Execution
        viewModel
            .fetchSectionResult
            .execute(true)
    }
}

// MARK: - UITableViewDelegate

extension ListSectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let hw = Bundle.main.loadNibNamed("SectionHeaderView", owner: self, options: nil)?.first as? SectionHeaderView else { return nil }
        
        viewModel
            .trainStatus
            .drive(hw.trainStatusLabel.rx.text)
            .disposed(by: bag)
        
        viewModel
            .trainNumber
            .drive(hw.trainNumber.rx.text)
            .disposed(by: bag)
        
        return hw
    }
}
