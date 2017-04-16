//
//  DataProviderTests.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2017-04-11.
//  Copyright © 2017 Felipe Dias Pereira. All rights reserved.
//

import XCTest
@testable import Listio

class DataProviderTests: XCTestCase {
    var viewController: MainViewController!
    
    class MockDataProvider: NSObject, DataProviderProtocol {
        
        var coreDataHandler: CoreDataHandler!
        weak var tableView: UITableView!
        func fetch() { }
        func addReceipt(_ json:[String: AnyObject]) { }
        func calcMediumCost() -> Double { return 17.1 }
        func getCountItems() -> Int { return 3 }
        required init(coreDataHandler: CoreDataHandler) {
            super.init()
            self.coreDataHandler = coreDataHandler
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 3
        }
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "", for: indexPath)
            return cell
        }
    }
    
    override func setUp() {
        super.setUp()
        viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainViewController") as! MainViewController
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testTableView() {
        // given
        // 1
        let mockDataProvider = MockDataProvider(coreDataHandler: CoreDataHandler(mainContext: setUpInMemoryManagedObjectContext()))
        
        viewController.dataProvider = mockDataProvider
        
        // when
        // 2
        XCTAssertNil(mockDataProvider.tableView, "Before loading the table view should be nil")
        
        // 3
        let _ = viewController.view
        // then
        // 4
        XCTAssertTrue(mockDataProvider.tableView != nil, "The table view should be set")
        XCTAssert(mockDataProvider.tableView === viewController.tableView,
                  "The table view should be set to the table view of the data source")
    }
    
    
    
}
