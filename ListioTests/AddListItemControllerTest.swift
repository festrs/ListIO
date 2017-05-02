//
//  AddListItemControllerTest.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2017-04-26.
//  Copyright © 2017 Felipe Dias Pereira. All rights reserved.
//

import XCTest
import DATAStack
@testable import Listio

class AddListItemControllerTest: XCTestCase {
    var viewController: AddListItemViewController!
    
    class MockDataProvider: NSObject, AddListItemDataProviderProtocol {
        var dataStack: DATAStack!
        weak var tableView: UITableView!
        public var shouldCallPerformFecth:Bool = false
        
        func performFetch() throws {
            shouldCallPerformFecth = true
        }
        func countItems() -> Int {
            return 2
        }
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 2
        }
        func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            return AddListItemTableViewCell()
        }
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
        }
    }
    
    
    override func setUp() {
        super.setUp()
        viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addListItemController") as! AddListItemViewController
        
        viewController.dataProvider = MockDataProvider()
        
        let _ = viewController.view
    }
    
    override func tearDown() {
        super.tearDown()
        viewController = nil
    }
    
    
    func testSUT_TableViewIsNotNilAfterViewDidLoad() {
        
        XCTAssertNotNil(viewController.tableView)
    }
    
    func testSUT_ShouldSetTableViewDataSource() {
        
        XCTAssertNotNil(viewController.tableView.dataSource)
    }
    
    func testSUT_ShouldSetTableViewDelegate() {
        
        XCTAssertNotNil(viewController.tableView.delegate)
    }
    
    func testSUT_ConformsToTableViewDataSourceProtocol() {
        
        XCTAssert((viewController.dataProvider?.responds(to: #selector(UITableViewDataSource.numberOfSections(in:))))!)
        
        XCTAssert((viewController.dataProvider?.responds(to: #selector(UITableViewDataSource.tableView(_:numberOfRowsInSection:))))!)
        
        XCTAssert((viewController.dataProvider?.responds(to: #selector(UITableViewDataSource.tableView(_:cellForRowAt:))))!)
        
    }
    
    func testSUT_TableViewUsesCustomCell_SearchItemTableViewCell() {
        
        let cell = viewController.dataProvider?.tableView(viewController.tableView, cellForRowAt: IndexPath(row: 0, section: 0))
        
        XCTAssert(cell is AddListItemTableViewCell) //whatever the name of your UITableViewCell subclass
    }
    
    func testShouldCallPerformFetch() {
        UIApplication.topViewController()?.present(viewController, animated: true, completion: nil)
        
        //XCTAssertTrue(viewController.dataProvider.shouldCallPerformFecth)
    }
    
}
