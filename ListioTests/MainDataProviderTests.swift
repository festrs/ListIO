//
//  DataProviderTests.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2017-04-11.
//  Copyright © 2017 Felipe Dias Pereira. All rights reserved.
//

import XCTest
import CoreData
import DATAStack

@testable import Listio

class MainDataProviderTests: XCTestCase {

    var dataProvider: MainDataProvider!
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
        dataProvider = MainDataProvider()
        dataProvider.dataStack = dataStack
    }

    override func tearDown() {
        super.tearDown()
        mockAPI = nil
        dataProvider = nil
    }
    
    func setUpAddReceipt1() {
        XCTAssertNotNil(receipt1, "JSON file should not be nil")
        do {
            try Receipt.createReceipt(dataStack.mainContext, json: receipt1!)
            XCTAssertTrue(true)
        } catch {
            XCTFail("error throwed")
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
    
    func testDuplicateAddTryReceipt() {
        setUpAddReceipt1()
        
        XCTAssertThrowsError(try Receipt.createReceipt(dataStack.mainContext, json: receipt1!)) { error in
            switch error as! Errors {
            case .DoubleReceiptWithSameID:
                XCTAssertTrue(true)
            default:
                XCTAssertTrue(false)
            }
        }
    }

    func testGetReceipts() {
        
        do {
            let count = try dataProvider.getAllReceipt()?.count
            XCTAssertEqual(0, count)
        } catch {
            XCTFail("error throwed")
        }
    
        setUpAddReceipt1()
        
        do {
            let count = try dataProvider.getAllReceipt()?.count
            XCTAssertEqual(1, count)
        } catch {
            XCTFail("error throwed")
        }
    }

    func testCalMediumValueReceipts() {
        setUpAddReceipt1()
        setUpAddReceipt2()
        do {
            let mediumCost = try dataProvider.calcMediumCost()
            XCTAssertEqual(mediumCost, 16.25)
        } catch {
            XCTFail("error throwed")
        }
    }


    func testReceiptModelFetch() {
        setUpAddReceipt1()
        
        //then
        do{
            if #available(iOS 10.0, *) {
                let request: NSFetchRequest<Listio.Receipt> = Listio.Receipt.fetchRequest()
                let result = try dataProvider.dataStack.mainContext.fetch(request)
                XCTAssertNotNil(result)
            } else {
                XCTAssertTrue(true)
            }
        } catch let error as NSError {
            XCTFail("Could not fetch \(error), \(error.userInfo)")
        }
        
    }

    func testItemModelFetch() {
        setUpAddReceipt1()
        
        //then
        do{
            if #available(iOS 10.0, *) {
                let request: NSFetchRequest<Listio.Item> = Listio.Item.fetchRequest()
                let result = try dataProvider.dataStack.mainContext.fetch(request)
                
                XCTAssertEqual(try dataProvider.getAllItems()!, result)
                
                XCTAssertNotNil(result)
            } else {
                XCTAssertTrue(true)
            }
        } catch let error as NSError {
            XCTFail("Could not fetch \(error), \(error.userInfo)")
        }
    }

    func testCountAllItems() {
        setUpAddReceipt1()
        setUpAddReceipt2()
        
        do {
            let itemsCount = try dataProvider.getAllItems()?.count
            XCTAssertEqual(itemsCount, 6)
        } catch {
            XCTFail("error throwed")
        }
    }
    
}
