//
//  ItemTest.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2017-05-03.
//  Copyright © 2017 Felipe Dias Pereira. All rights reserved.
//

import XCTest
import DATAStack
import CoreData
@testable import Listio

class ItemTest: XCTestCase {
    var mockAPI: MockAPICommunicator!
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
    
    class MockMOC : NSManagedObjectContext {
        
        override func fetch(_ request: NSFetchRequest<NSFetchRequestResult>) throws -> [Any] {
            throw Errors.CoreDataError("test")
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
        setUpAddReceipt1()
        setUpAddReceipt2()
    }
    
    override func tearDown() {
        super.tearDown()
        mockAPI = nil
        dataStack = nil
        receipt1 = nil
        receipt2 = nil
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
    
    func testGetAllItems() {
        do {
            let itemsCount = try Item.getAllItems(dataStack.mainContext)?.count
            XCTAssertEqual(itemsCount, 6)
        } catch {
            XCTFail("error throwed")
        }
    }
    
    func testCountUniqueItems() {
        do {
            let itemsCount = try Item.getUniqueItems(dataStack.mainContext)?.count
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
    
    func testItemErros() {
        let context = MockMOC(concurrencyType: .mainQueueConcurrencyType)
        XCTAssertThrowsError(try Item.getUniqueItems(context))
        XCTAssertThrowsError(try Item.getAllItems(context))
    }
}
