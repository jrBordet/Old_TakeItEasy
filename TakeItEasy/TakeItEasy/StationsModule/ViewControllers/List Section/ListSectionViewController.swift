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
import RxCoreData

protocol ListSectionCoordinator {
    func showTrainSections(of departureCode: String, trainCode: String)
}

class ListSectionViewController: UIViewController {
    
    @IBOutlet var sessionTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var sessionVariable = Variable<[Section?]>([nil])
    lazy var sessionObservable: Observable<[Section?]> = sessionVariable.asObservable()
    
    final var coordinatorDelegate: ListSectionCoordinator?
    
    final var travel: Travel?
    
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let travel = travel else { return }
        
        // Table view
        _ = sessionTableView
            .rx
            .setDelegate(self)
        
        bindUI()
        
        title = travel.direction
        
        TravelTrainAPI
            .trainSections(of: travel.originCode, String(travel.number))
            .map ({ [weak self] section -> Bool in
                self?.sessionVariable.value = section
                
                return true
            })
            .bind(to: activityIndicator.rx.isAnimating)
            .disposed(by: bag)
    }
    
    // MARK: - Privates
    
    private func bindUI() {
        sessionObservable.bind(to: sessionTableView.rx.items(cellIdentifier: "SectionCell", cellType: SectionCell.self)) { index, model, cell in
            guard let model = model else { return }
            
            cell.stationLabel.text = model.station.capitalized
            cell.hourlabel.text = model.departureHour
            
            if model.current {
                cell.hourlabel.textColor = UIColor.green
            } else {
                cell.hourlabel.textColor = UIColor.lightGray
            }
            
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
