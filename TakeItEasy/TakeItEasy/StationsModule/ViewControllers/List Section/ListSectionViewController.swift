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
    
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindUI()
        
//        TravelTrainAPI
//        .trainSections(of: "", "")
//        .map ({ (section: [Section?]) -> Bool in
//                return true
//        })
        
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
                        debugPrint(model)
                        //cell.textLabel?.text = model?.departureDate
//                        if let model = model {
//                            cell.textLabel?.text = "msdfsdfhdsfh"
//                        }
            }
            .disposed(by: bag)
    }
}
