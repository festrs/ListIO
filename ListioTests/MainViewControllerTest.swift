//
//  MainViewControllerTest.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2017-04-17.
//  Copyright © 2017 Felipe Dias Pereira. All rights reserved.
//

import XCTest
import DATAStack
import MockUIAlertController

@testable import Listio

class MainViewControllerTest: XCTestCase {
    var viewController: MainViewController!
    var alertVerifier: QCOMockAlertVerifier!
    
//    class MockDataProvider: NSObject, MainDataProviderProtocol, UITableViewDataSource {
//        func calcMediumCost() -> Double {
//            return 0.0
//        }
//
//        var items: [Item]
//        
//        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//        }
//        
//        var dataStack: DATAStack!
//        weak var tableView: UITableView!
//        
//        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//            return 1
//        }
//        func numberOfSections(in tableView: UITableView) -> Int {
//            return 1
//        }
//        
//        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//            return MainTableViewCell()
//        }
//        
//        func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//            
//        }
//        
//        func performFetch() throws {
//            
//        }
//        
//        func addReceipt(_ json:[String: AnyObject]) throws {
//            
//        }
//        func calcMediumCost() throws -> Double {
//            return 14.4
//        }
//        func getCountItems() -> Int {
//            return 1
//        }
//        
//        required init(DATAStack: DATAStack){
//            super.init()
//        }
//    }
//
//    
//    override func setUp() {
//        super.setUp()
//        viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainViewController") as! MainViewController
//        
//        let dataStack = DATAStack(modelName: "Listio", bundle: Bundle.main, storeType: .inMemory)
//        
//        viewController.dataProvider = MockDataProvider(DATAStack: dataStack)
//        
//        alertVerifier = QCOMockAlertVerifier()
//        
//        let _ = viewController.view
//    }
//    
//    override func tearDown() {
//        alertVerifier = nil
//        viewController = nil
//        super.tearDown()
//    }
//    
//    
//    func testSUT_TableViewIsNotNilAfterViewDidLoad() {
//        
//        XCTAssertNotNil(viewController.tableView)
//    }
//    
//    func testSUT_ShouldSetTableViewDataSource() {
//        
//        XCTAssertNotNil(viewController.tableView.dataSource)
//    }
//    
//    func testSUT_ConformsToTableViewDataSourceProtocol() {
//        
//        XCTAssert((viewController.dataProvider?.conforms(to: UITableViewDataSource.self))!)
//        
//        XCTAssert((viewController.dataProvider?.responds(to: #selector(UITableViewDataSource.numberOfSections(in:))))!)
//        
//        XCTAssert((viewController.dataProvider?.responds(to: #selector(UITableViewDataSource.tableView(_:numberOfRowsInSection:))))!)
//        
//        XCTAssert((viewController.dataProvider?.responds(to: #selector(UITableViewDataSource.tableView(_:cellForRowAt:))))!)
//        
//    }
//    
//    func testSUT_TableViewUsesCustomCell_SearchItemTableViewCell() {
//        
//        let cell = viewController.dataProvider?.tableView(viewController.tableView, cellForRowAt: IndexPath(row: 0, section: 0))
//        
//        XCTAssert(cell is MainTableViewCell) //whatever the name of your UITableViewCell subclass
//    }
//    
//    func testEditTableView() {
//        
//        XCTAssertFalse(viewController.tableView.isEditing)
//        
//        viewController.editTableView(UIButton(type: .custom))
//        
//        XCTAssert(viewController.tableView.isEditing)
//    }
}
