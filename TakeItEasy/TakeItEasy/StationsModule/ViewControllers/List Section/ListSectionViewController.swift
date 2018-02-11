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
    @IBOutlet var headerInformationLabel: UILabel!
    
    private var sessionVariable = Variable<[Section?]>([nil])
    lazy var sessionObservable: Observable<[Section?]> = sessionVariable.asObservable()
    
    final var coordinatorDelegate: ListSectionCoordinator?
    
    final var travel: Travel?
    
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Table view
        _ = sessionTableView
            .rx
            .setDelegate(self)
        
        bindUI()
        
        guard let travel = travel else { return }
        
        TravelTrainAPI
            .trainSections(of: travel.originCode, String(travel.number))
            .map ({ [weak self] section -> Bool in
                self?.sessionVariable.value = section
                
                return true
            })
            .bind(to: activityIndicator.rx.isAnimating)
            .disposed(by: bag)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Privates
    
    private func bindUI() {
        sessionObservable
            .bind(to:
                sessionTableView
                    .rx
                    .items(cellIdentifier: "SectionCell", cellType: SectionCell.self)) { index, model, cell in
                        if let model = model {
                            cell.stationLabel.text = model.station.capitalized
                            cell.hourlabel.text = model.departureHour
                            
                            if model.current {
                                cell.hourlabel.textColor = UIColor.green
                                
//                                cell.stationLabel.transform = CGAffineTransform(scaleX: 2.6, y: 2.6)
//                                cell.stationLabel.alpha = 0.3
//
//                                UIView.animate(withDuration: 0.7, animations: {
//                                    cell.stationLabel.transform = CGAffineTransform.identity
//                                    cell.stationLabel.alpha = 1.0
//                                })
                                
                            } else {
                                cell.hourlabel.textColor = UIColor.lightGray
                            }
                            
                           // cell.isCurrentStation = model.current
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
