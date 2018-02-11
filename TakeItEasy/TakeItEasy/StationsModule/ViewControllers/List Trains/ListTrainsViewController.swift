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

protocol ListTrainsCoordinator {
    func showTravelDetail(of travel: Travel)
}

class ListTrainsViewController: UIViewController {
    @IBOutlet weak var departuresTableView: UITableView!
    @IBOutlet weak var directionControl: UISegmentedControl!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    final var station: Station?
    
    private var trainsVariable = Variable<[Travel?]>([nil])
    lazy var trainsObservable: Observable<[Travel?]> = trainsVariable.asObservable()
    
    var refreshControl: UIRefreshControl!
    
    private let bag = DisposeBag()
    
    final var coordinatorDelegate: ListTrainsCoordinator?
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Table view
        _ = departuresTableView
            .rx
            .setDelegate(self)
        
        // Segmented control for directions
        directionControl
            .rx
            .selectedSegmentIndex.subscribe { [weak self] (index) in
                if let index = index.element
                {
                    self?.performUpdate(of: index, completion: nil)
                }
            }
            .disposed(by: bag)
        
        // Refresh controll to pull
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = .green
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        departuresTableView.addSubview(refreshControl)
        
        // UI
        activityIndicator.startAnimating()
        
        bindUI()
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
    
    @objc func refresh(sender:AnyObject) {
        performUpdate(of: directionControl.selectedSegmentIndex) {
            DispatchQueue.main.async(execute: {
                self.refreshControl.endRefreshing()
            })
        }
    }
    
    private func performUpdate(of index: Int, completion: (() -> ())?) {
        if let station = station, index == 0 {
            TravelTrainAPI
                .trainDepartures(of: station.id)
                .map({ [weak self] departures -> Bool in
                    self?.trainsVariable.value = departures
                    
                    if let completion = completion {
                        completion()
                    }

                    return false
                })
                .bind(to: activityIndicator.rx.isAnimating)
                .disposed(by: bag)
        } else if let station = station, index == 1 {
            TravelTrainAPI
                .trainArrivals(of: station.id)
                .map({ [weak self] departures -> Bool in
                    self?.trainsVariable.value = departures
                    
                    if let completion = completion {
                        completion()
                    }
                    
                    return false
                })
                .bind(to: activityIndicator.rx.isAnimating)
                .disposed(by: bag)
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
