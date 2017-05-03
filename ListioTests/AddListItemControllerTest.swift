//
//  AddListItemControllerTest.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2017-04-26.
//  Copyright © 2017 Felipe Dias Pereira. All rights reserved.
//

import XCTest
import DATAStack
import CoreData

@testable import Listio

class AddListItemControllerTest: XCTestCase {
    var viewController: AddListItemViewController!
    var mockAPI: MockAPICommunicator!
    var dataProvider: AddListItemDataProviderProtocol!
    var dataStack: DATAStack!
    var receipt1:[String: AnyObject]? = nil
    var receipt2:[String: AnyObject]? = nil
    
    class MockAPICommunicator : APICommunicatorProtocol {
        
        func getReceipt(linkUrl: String, _ completion: @escaping (Error?, [String : AnyObject]?) -> Void) {
            completion(nil,readJson(name: linkUrl))
        }
        
        private func readJson(name : String) -> [String: AnyObject]? {
            guard let pathString = Bundle(for: type(of: self)).path(forResource: name, ofType: "json") else {
                fatalError("UnitTestData.json not found")
            }
            
            guard let jsonString = try? NSString(contentsOfFile: pathString, encoding: String.Encoding.utf8.rawValue) else {
                fatalError("Unable to convert UnitTestData.json to String")
            }
            
            guard let jsonData = jsonString.data(using: String.Encoding.utf8.rawValue) else {
                fatalError("Unable to convert UnitTestData.json to NSData")
            }
            
            guard let jsonDictionary = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String:AnyObject] else {
                fatalError("Unable to convert UnitTestData.json to JSON dictionary")
            }
            return jsonDictionary
        }
    }
    
    class MockDataProvider: NSObject, AddListItemDataProviderProtocol {
        var dataStack: DATAStack!
        weak var tableView: UITableView!
        var shouldCallPerformFecth:Bool = false
        
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
    
    func setUpAddReceipt1() {
        XCTAssertNotNil(receipt1, "JSON file should not be nil")
        do {
            try Receipt.createReceipt(dataStack.mainContext, json: receipt1!)
            XCTAssertTrue(true)
        } catch Errors.CoreDataError(let msg) {
            XCTFail("error throwed" + msg)
        } catch {
            
        }
    }
    
    func setUpAddReceipt2() {
        XCTAssertNotNil(receipt2, "JSON file should not be nil")
        do {
            try Receipt.createReceipt(dataStack.mainContext, json: receipt2!)
            XCTAssertTrue(true)
        } catch {
            XCTFail("error throwed")
        }
    }
    
    override func setUp() {
        super.setUp()
        viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addListItemController") as! AddListItemViewController
        
        mockAPI = MockAPICommunicator()
        
        mockAPI.getReceipt(linkUrl: "receipt1") { (error, responseJSON) in
            self.receipt1 = responseJSON
        }
        
        mockAPI.getReceipt(linkUrl: "receipt2") { (error, responseJSON) in
            self.receipt2 = responseJSON
        }
        
        dataStack = DATAStack(modelName: "Listio", bundle: Bundle.main, storeType: .inMemory)
        dataProvider = AddListItemDataProvider()
        dataProvider.dataStack = dataStack
        
        setUpAddReceipt1()
        setUpAddReceipt2()
    }
    
    override func tearDown() {
        super.tearDown()
        viewController = nil
    }
    
    func testSUT_ConformsToTableViewDataSourceProtocol() {
        
        XCTAssert((dataProvider.responds(to: #selector(UITableViewDataSource.tableView(_:numberOfRowsInSection:)))))
        
        XCTAssert((dataProvider.responds(to: #selector(UITableViewDataSource.tableView(_:cellForRowAt:)))))
        
    }

    
    func testSUT_TableViewUsesCustomCell_AddListItemTableViewCell() {
        viewController.dataProvider = MockDataProvider()
        
        let _ = viewController.view
        
        let cell = viewController.dataProvider?.tableView(viewController.tableView, cellForRowAt: IndexPath(row: 0, section: 0))
        
        XCTAssert(cell is AddListItemTableViewCell) //whatever the name of your UITableViewCell subclass
    }
    
    
    func testSUT_TableViewIsNotNilAfterViewDidLoad() {
        viewController.dataProvider = dataProvider
        
        let _ = viewController.view
        
        XCTAssertNotNil(viewController.tableView)
    }
    
    func testSUT_ShouldSetTableViewDataSource() {
        viewController.dataProvider = dataProvider
        
        let _ = viewController.view
        
        XCTAssertNotNil(viewController.tableView.dataSource)
    }
    
    func testSUT_ShouldSetTableViewDelegate() {
        viewController.dataProvider = dataProvider
        
        let _ = viewController.view
        
        XCTAssertNotNil(viewController.tableView.delegate)
    }
    
    func testShouldCallPerformFetch() {
        
        let mock = MockDataProvider()
        
        viewController.dataProvider = mock
        
        let _ = viewController.view
        
        viewController.viewWillAppear(true)
        
        XCTAssertTrue(mock.shouldCallPerformFecth)
    
    }
    
}
