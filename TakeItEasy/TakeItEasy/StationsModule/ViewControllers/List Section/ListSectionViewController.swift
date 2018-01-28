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

class ListSectionViewController: UITableViewController {
    
    @IBOutlet var sessionTableView: UITableView!
    
    private var sessionVariable = Variable<[TravelDetail?]>([nil])
    lazy var sessionObservable: Observable<[TravelDetail?]> = self.sessionVariable.asObservable()
    
    final var coordinatorDelegate: ListSectionCoordinator?
    
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
