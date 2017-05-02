//
//  AddListItemDataProviderTest.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2017-04-26.
//  Copyright © 2017 Felipe Dias Pereira. All rights reserved.
//

import XCTest
import DATAStack

@testable import Listio

class AddListItemDataProviderTest: XCTestCase {
    
    var mockAPI: MockAPICommunicator!
    var dataProvider: AddListItemDataProviderProtocol!
    var mainDataProvider: MainDataProviderProtocol!
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
    
    override func setUp() {
        super.setUp()
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
        
        mainDataProvider = MainDataProvider()
        mainDataProvider.dataStack = dataStack
        
        setUpAddReceipt1()
        setUpAddReceipt2()
    }
    
    override func tearDown() {
        super.tearDown()
        mockAPI = nil
        dataStack = nil
        dataProvider = nil
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
    
    func testSUT_ConformsToTableViewDataSourceProtocol() {
        
        XCTAssert(dataProvider.responds(to: #selector(UITableViewDataSource.numberOfSections(in:))))
        
        XCTAssert((dataProvider.responds(to: #selector(UITableViewDataSource.tableView(_:numberOfRowsInSection:)))))
        
        XCTAssert((dataProvider.responds(to: #selector(UITableViewDataSource.tableView(_:cellForRowAt:)))))
        
    }
    
    func testPerformFetch() {
        XCTAssertEqual(dataProvider.countItems(), 0)
        do {
            try dataProvider.performFetch()
            XCTAssertEqual(dataProvider.countItems(), 4)
        }catch {
            XCTFail("error throwed")
        }
    }
    
    func testCountUniqueItems() {
        do {
            try dataProvider.performFetch()
            let itemsCount = dataProvider.countItems()
            XCTAssertEqual(itemsCount, 4)
        } catch {
            XCTFail("error throwed")
        }
    }
    
    func testItemCountReceipts() {
        do {
            var items = try Item.getUniqueItems(dataStack.mainContext)
            
            items = items?.filter({ (item) -> Bool in
                return (item.countReceipt?.intValue)! > 1
            })
            
            XCTAssertEqual(items?.count, 2)
        } catch {
            XCTFail("error throwed")
        }
    }
    
    func testFetch() {

        do {
            try dataProvider.performFetch()
        } catch {
            XCTFail("error throwed")
        }
        //XCTAssertNotEqual([Item](), dataProvider.items)
    }
    

    
}
