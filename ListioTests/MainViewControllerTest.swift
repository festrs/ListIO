//
//  MainViewControllerTest.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2017-04-17.
//  Copyright © 2017 Felipe Dias Pereira. All rights reserved.
//

import XCTest
import DATAStack
@testable import Listio

class MainViewControllerTest: XCTestCase {
    var viewController: MainViewController!
    
    class MockDataProvider: NSObject, DataProviderProtocol, UITableViewDataSource {
        
        var dataStack: DATAStack!
        weak var tableView: UITableView!
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 1
        }
        func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            return DocumentUiTableViewCell()
        }
        
        func fetch() throws {
            
        }
        func addReceipt(_ json:[String: AnyObject]) throws {
            
        }
        func calcMediumCost() throws -> Double {
            return 14.4
        }
        func getCountItems() throws -> Int {
            return 1
        }
        
        required init(DATAStack: DATAStack){
            super.init()
        }
    }

    
    override func setUp() {
        super.setUp()
        viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainViewController") as! MainViewController
        
        let dataStack = DATAStack(modelName: "Listio", bundle: Bundle.main, storeType: .inMemory)
        
        viewController.dataProvider = MockDataProvider(DATAStack: dataStack)
        
        let _ = viewController.view
    }
    
    
    func testSUT_TableViewIsNotNilAfterViewDidLoad() {
        
        XCTAssertNotNil(viewController.tableView)
    }
    
    func testSUT_ShouldSetTableViewDataSource() {
        
        XCTAssertNotNil(viewController.tableView.dataSource)
    }
    
    func testSUT_ShouldSetTableViewDelegate() {
        
        XCTAssertNotNil(viewController.tableView.dataSource)
    }
    
    func testSUT_ConformsToTableViewDataSourceProtocol() {
        
        XCTAssert((viewController.dataProvider?.conforms(to: UITableViewDataSource.self))!)
        
        XCTAssert((viewController.dataProvider?.responds(to: #selector(viewController.dataProvider?.numberOfSections(in:))))!)
        
        XCTAssert((viewController.dataProvider?.responds(to: #selector(UITableViewDataSource.tableView(_:numberOfRowsInSection:))))!)
        
        XCTAssert((viewController.dataProvider?.responds(to: #selector(UITableViewDataSource.tableView(_:cellForRowAt:))))!)
        
    }
    
    func testSUT_TableViewUsesCustomCell_SearchItemTableViewCell() {
        
        let cell = viewController.dataProvider?.tableView(viewController.tableView, cellForRowAt: IndexPath(row: 0, section: 0))
        
        XCTAssert(cell is DocumentUiTableViewCell) //whatever the name of your UITableViewCell subclass
    }
    
    func testSUT_ConformsToTableViewDelegateProtocol() {
        
        XCTAssert((viewController.conforms(to: UITableViewDelegate.self)))
        
    }
    
}
