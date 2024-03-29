//
//  StationModule.swift
//  ViaggioTreno
//
//  Created by Jean Raphael on 16/11/2017.
//  Copyright © 2017 Jean Raphael. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources

class RouterStation {
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    var navigation: UINavigationController!
    
    let spotlightTransition = SpotlightTransition()

    let bag = DisposeBag()
    
    final func assembleModule() {
        createRootViewController(with: createListUserStationViewController)
    }
    
    // MARK: - Factory methods
    
    private func createListUserStationViewController() -> UIViewController {
        let listUserStationViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserStationViewController") as! ListUserStationViewController
        
        listUserStationViewController.viewModel = UserStationViewModel(dependencies: DataManager.shared)
        listUserStationViewController.coordinatorDelegate = self as ListUserStationCoordinator
        
        return listUserStationViewController
    }
    
    private func createListUserTrainViewController() -> UIViewController {
        let listUserStationViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserTrainsViewController") as! ListUserTrainsViewController
        
        listUserStationViewController.viewModel = UserTrainViewModel(dependencies: DataManager.shared)
        listUserStationViewController.coordinatorDelegate = self as ListUserTrainsCoordinator
        
        return listUserStationViewController
    }
    
    private func createListSpotlightViewController() -> UIViewController {
        let listSpotlightViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ListSpotlightViewController") as! ListSpotlightViewController
        
        listSpotlightViewController.transitioningDelegate = spotlightTransition
        
        listSpotlightViewController.coordinatorDelegate = self as ListSpotlightCoordinator
        listSpotlightViewController.dataManager = DataManager.shared
        
        return listSpotlightViewController
    }
    
    private func createListTrainViewController(of station: Station) -> UIViewController {
        let listTrainsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TrainsViewController") as! ListTrainsViewController
        
        listTrainsViewController.viewModel = UserTrainViewModel(dependencies: DataManager.shared,
                                                                input: (station: station, date: Date()))
        listTrainsViewController.coordinatorDelegate = self
        
        return listTrainsViewController
    }
    
    private func createListSectionViewController(of travel: Travel) -> UIViewController {
        let listSectionViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SectionViewController") as! ListSectionViewController
        
        listSectionViewController.viewModel = SectionViewModel(travel: travel)
        
        return listSectionViewController
    }
    
    // MARK: - Privates
    
    func createRootViewController(with changeFunction: () -> UIViewController) {
        navigation = UINavigationController(rootViewController: changeFunction())
        
        navigation.navigationBar.barTintColor = .black
        navigation.navigationBar.tintColor = UIColor(named: "primayGreen") ?? .green
        navigation.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.lightGray]
        navigation.navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        
//        if #available(iOS 11.0, *) {
//            navigation.navigationBar.prefersLargeTitles = true
//            navigation.navigationItem.largeTitleDisplayMode = .automatic
//            
//            UINavigationBar.appearance().largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.lightGray]
//        }
        
        UIView.transition(with: appdelegate.window!, duration: 0.28, options: .transitionCrossDissolve, animations: {
            self.appdelegate.window!.rootViewController = self.navigation
        })
    }
}

// MARK: - ListTrainsCoordinator

extension RouterStation: ListTrainsCoordinator {
    func showTravelDetail(of travel: Travel) {
        navigation.pushViewController(createListSectionViewController(of: travel), animated: true)
    }
}

// MARK: - ListUserTrainsCoordinator

extension RouterStation: ListUserTrainsCoordinator {
    func showStations() {
        createRootViewController(with: createListUserStationViewController)
    }
}

// MARK: - ListSpotlightCoordinator

extension RouterStation: ListSpotlightCoordinator {
    func showTrains(of station: Station) {
        navigation.pushViewController(createListTrainViewController(of: station), animated: true)
    }
    
    func showMyStations() {
        navigation.dismiss(animated: true, completion: nil)
    }
}

// MARK: - ListUserStationCoordinator

extension RouterStation: ListUserStationCoordinator {
    func showTrains() {
        createRootViewController(with: createListUserTrainViewController)
    }
    
    func showDepartures(of station: Station) {
        navigation.pushViewController(createListTrainViewController(of: station), animated: true)
    }
    
    func showTrainSpootlight() {
        navigation.present(createListSpotlightViewController(), animated: true, completion: nil)
    }
}
