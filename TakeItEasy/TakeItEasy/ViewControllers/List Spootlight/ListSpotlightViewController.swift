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
import Foundation

protocol ListSpotlightCoordinator {
    func showTrains(of station: Station)
    
    func showMyStations()
}

class ListSpotlightViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet var closeView: UIView! {
        didSet {
            closeView.layer.cornerRadius = 3
            closeView.layer.masksToBounds = true
        }
    }
    
    @IBOutlet var closeContainerView: UIView! {
        didSet {
            closeContainerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            closeContainerView.layer.cornerRadius = 12
        }
    }
    
    // MARK: - Privates
    
    private let bag = DisposeBag()
    
    var swipeInteractionController: SwipeInteractionController?

    private var query: String = ""

    // MAR: - Coordinator
    
    final var coordinatorDelegate: ListSpotlightCoordinator?    
    
     // MARK: - Dependencies
    
    final var dataManager: DataManagerProtocol?
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if DEBUG
        let logString = "⚠️ Number of start resources = \(Resources.total) ⚠️"
        debugPrint(logString)
        #endif
        
        searchBar.becomeFirstResponder()
        
        // Configure custom dismiss transition
        swipeInteractionController = SwipeInteractionController(viewController: self, view: closeContainerView)
        
        bindUI()
    }
    
    deinit {
        debugPrint("\(self) deinit")
    }
    
    // MARK: - Binding
    
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
                
                cell.backgroundColor = .clear
                cell.textLabel?.textColor = UIColor.darkGray
                
                let stationNameAttributed = NSMutableAttributedString(string: station.name.capitalizingFirstLetter())
                stationNameAttributed.addAttributes([NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 17),
                                                     NSAttributedStringKey.foregroundColor: UIColor.white ],
                                                    range:(stationNameAttributed.string as NSString).range(of: self.query))
                
                cell.textLabel?.attributedText = stationNameAttributed
                
                return cell
            }
            .disposed(by: bag)
        
        searchBar
            .rx
            .searchButtonClicked.subscribe(onNext: { [weak self] _ in
                self?.searchBar.resignFirstResponder()
            })
            .disposed(by: bag)
        
        // MARK: - Selected
        
        tableView
            .rx
            .modelSelected(Station.self)
            .subscribe(onNext: { [weak self] s in
                self?.dataManager?.save(model: s)
                
                self?.searchBar.resignFirstResponder()
                
                guard let coordinator = self?.coordinatorDelegate else { return }
                
                coordinator.showMyStations()
            })
            .disposed(by: bag)
        
        // MARK: - Did Scroll
        
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
        guard let coordinator = self.coordinatorDelegate else { return }
        
        coordinator.showMyStations()
    }
    
}
