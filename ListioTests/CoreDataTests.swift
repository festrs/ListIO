//
//  CoreDataTests.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2017-04-11.
//  Copyright © 2017 Felipe Dias Pereira. All rights reserved.
//

import XCTest
import CoreData
@testable import Listio

class CoreDataTests: XCTestCase {
    
    var coreDataHelper: CoreDataHandler!
    var mockAPI: MockAPICommunicator!
    var response:[String: AnyObject]? = nil

    class MockAPICommunicator : APICommunicatorProtocol {
        
        func getReceipt(linkUrl: String, _ completion: @escaping (Error?, [String : AnyObject]?) -> Void) {
            completion(nil,readJson())
        }
        
        private func readJson() -> [String: AnyObject]? {
            guard let pathString = Bundle(for: type(of: self)).path(forResource: "JSON", ofType: "json") else {
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
        // 1
        coreDataHelper = CoreDataHandler(mainContext: setUpInMemoryManagedObjectContext())
        mockAPI = MockAPICommunicator()
        
        mockAPI.getReceipt(linkUrl: "") { (error, responseJSON) in
            self.response = responseJSON
        }
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testAddedNewReceipt() {

        XCTAssertNotNil(response, "JSON file should not be nil")
        
        XCTAssertTrue(coreDataHelper.savingData(response!))
        
        // not accepted same receipt 2x
        XCTAssertFalse(coreDataHelper.savingData(response!))
        
    }
    
    func testRemovedRedundancy() {

        XCTAssertNotNil(response, "JSON file should not be nil")
        
        XCTAssertTrue(coreDataHelper.savingData(response!))
        
        let allItems = coreDataHelper.getAllItems()
        
        XCTAssertEqual(3, allItems?.count)
    }
    
    func testFuzzy45() {
        let name1 = "PASTILHA TIC TAC CER"
        let name2 = "PASTILHA TIC TAC MIX"
        XCTAssertTrue(coreDataHelper.verifyItemByFuzzy(lhs: name1, rhs: name2))
    }
    
    func testGetReceipts() {

        XCTAssertNotNil(response, "JSON file should not be nil")
        
        XCTAssertEqual(0, coreDataHelper.getAllReceipt()?.count)
        
        XCTAssertTrue(coreDataHelper.savingData(response!))
        
        XCTAssertEqual(1, coreDataHelper.getAllReceipt()?.count)
    }
    
    func testCalMediumValueReceipts() {
        XCTAssertNotNil(response, "JSON file should not be nil")
        
        XCTAssertTrue(coreDataHelper.savingData(response!))
        
        XCTAssertEqual(coreDataHelper.calcMediumCost(), 13.75)
        
    }
    
    func testPerformanceAddedNewReceipt() {
        
        self.measure {
            var response:[String: AnyObject]? = nil
            self.mockAPI.getReceipt(linkUrl: "") { (error, responseJSON) in
                response = responseJSON
            }
            
            XCTAssertNotNil(response, "JSON file should not be nil")
            
            _ = self.coreDataHelper.savingData(response!)
        }
    }
    
    func testReceiptModelFetch() {
        //given
        XCTAssertNotNil(response, "JSON file should not be nil")
        
        //when
        XCTAssertTrue(coreDataHelper.savingData(response!))
        
        //then
        do{
            if #available(iOS 10.0, *) {
                let request: NSFetchRequest<Listio.Receipt> = Listio.Receipt.fetchRequest()
                let result = try coreDataHelper.mainContext.fetch(request)
                XCTAssertNotNil(result)
            } else {
                XCTAssertTrue(true)
            }
        } catch let error as NSError {
            XCTFail("Could not fetch \(error), \(error.userInfo)")
        }
        
    }
    
    func testItemModelFetch() {
        //given
        XCTAssertNotNil(response, "JSON file should not be nil")
        
        //when
        XCTAssertTrue(coreDataHelper.savingData(response!))
        
        //then
        do{
            if #available(iOS 10.0, *) {
                let request: NSFetchRequest<Listio.Item> = Listio.Item.fetchRequest()
                let result = try coreDataHelper.mainContext.fetch(request)
                XCTAssertNotNil(result)
            } else {
                XCTAssertTrue(true)
            }
        } catch let error as NSError {
            XCTFail("Could not fetch \(error), \(error.userInfo)")
        }
    }

}
