//
//  ListStationsViewController.swift
//  ViaggioTreno
//
//  Created by Jean Raphael on 12/11/2017.
//  Copyright © 2017 Jean Raphael. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CoreData
import Foundation

protocol ListSpotlightCoordinator {
    func showTrains(of station: Station)
    
    func showMyStations()
}

class ListSpotlightViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private let bag = DisposeBag()
    
    final var managedObjectContext: NSManagedObjectContext?
    
    final var coordinatorDelegate: ListSpotlightCoordinator?
    
    private var query: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.becomeFirstResponder()
        
        bindUI()
    }
    
    func bindUI() {
        searchBar
            .rx
            .text
            .orEmpty
            .throttle(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .filter { $0.count >= 1 ? true : false }
            .flatMapLatest { query -> Observable<[Station]> in
                if query.isEmpty {
                    return .just([])
                }
                
                self.query = query
                
                return TravelTrainAPI.trainStations(of: query)
                    .catchErrorJustReturn([])
            }
            .observeOn(MainScheduler.instance)
            .bind(to: tableView.rx.items) { tableView, index, station in
                let cell = UITableViewCell(style: .default, reuseIdentifier: "StationCell")
                
                cell.backgroundColor = UIColor.black
                cell.textLabel?.textColor = UIColor.lightGray
                
                let stationNameAttributed = NSMutableAttributedString(string: station.name.capitalizingFirstLetter())
                stationNameAttributed.addAttributes([NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 17),
                                                     NSAttributedStringKey.foregroundColor: UIColor.white ], range:(stationNameAttributed.string as NSString).range(of: self.query))
                
                cell.textLabel?.attributedText = stationNameAttributed
                
                return cell
            }
            .disposed(by: bag)
        
        searchBar
            .rx
            .searchButtonClicked.subscribe(onNext: { [unowned self] _ in
                self.searchBar.resignFirstResponder()
            })
            .disposed(by: bag)
        
        // MARK: - Selected
        
        tableView
            .rx
            .modelSelected(Station.self)
            .subscribe(onNext: { [weak self] station in
                if let mc = self?.managedObjectContext {
                    do {
                        try mc.rx.update(station)
                    } catch {
                        fatalError("\(String(describing: self)) fail on update \(station)")
                    }
                }
                
                if let coordinator = self?.coordinatorDelegate {                    
                    coordinator.showMyStations()
                }
            })
            .disposed(by: bag)
        
        tableView
            .rx
            .didScroll
            .subscribe(onNext: { [weak self] in
                self?.searchBar.resignFirstResponder()
            })
            .disposed(by: bag)
    }
    
    // MARK: - Navigation

    @IBAction func myStationsTap(_ sender: UIBarButtonItem) {
        if let coordinator = coordinatorDelegate {
            coordinator.showMyStations()
        }
    }
    
}
