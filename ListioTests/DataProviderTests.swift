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

class DataProviderTests: XCTestCase {
    var viewController: MainViewController!
    var dataProvider: DataProvider!
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
        viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainViewController") as! MainViewController
        mockAPI = MockAPICommunicator()
        
        mockAPI.getReceipt(linkUrl: "") { (error, responseJSON) in
            self.response = responseJSON
        }
        
        let dataStack = DATAStack(modelName: "Listio", bundle: Bundle.main, storeType: .inMemory)
        
        dataProvider = DataProvider(DATAStack: dataStack)
    
    }

    override func tearDown() {
        super.tearDown()
    }
    
    func testTableView() {
        // given
        // 1
        viewController.dataProvider = dataProvider
        
        // when
        // 2
        XCTAssertNil(dataProvider.tableView, "Before loading the table view should be nil")
        
        // 3
        let _ = viewController.view
        // then
        // 4
        XCTAssertTrue(dataProvider.tableView != nil, "The table view should be set")
        XCTAssert(dataProvider.tableView === viewController.tableView,
                  "The table view should be set to the table view of the data source")
    }
    
    func setUpAddReceipt() {
        XCTAssertNotNil(response, "JSON file should not be nil")
        do {
            try dataProvider.addReceipt(response!)
            XCTAssertTrue(true)
        } catch {
            XCTFail("error throwed")
        }
    }
    
    func testAddedNewReceipt() {
        
        setUpAddReceipt()
        
        XCTAssertThrowsError(try dataProvider.addReceipt(response!)) { error in
            switch error as! Errors {
            case .DoubleReceiptWithSameID:
                XCTAssertTrue(true)
            default:
                XCTAssertTrue(false)
            }
        }

    }
    
    func testRemovedRedundancy() {
        
        setUpAddReceipt()
        
        do {
            let allItems = try dataProvider.getAllItems()
            XCTAssertEqual(3, allItems?.count)
        } catch {
            XCTFail("error throwed")
        }
    }
    
    func testFuzzy45() {
        let name1 = "PASTILHA TIC TAC CER"
        let name2 = "PASTILHA TIC TAC MIX"
        XCTAssertTrue(dataProvider.verifyItemByFuzzy(lhs: name1, rhs: name2))
    }
    
    func testGetReceipts() {
        
        do {
            let count = try dataProvider.getAllReceipt()?.count
            XCTAssertEqual(0, count)
        } catch {
            XCTFail("error throwed")
        }
    
        setUpAddReceipt()
        
        do {
            let count = try dataProvider.getAllReceipt()?.count
            XCTAssertEqual(1, count)
        } catch {
            XCTFail("error throwed")
        }
        
    }

    func testCalMediumValueReceipts() {

        setUpAddReceipt()
        
        do {
            let mediumCost = try dataProvider.calcMediumCost()
            XCTAssertEqual(mediumCost, 13.75)
        } catch {
            XCTFail("error throwed")
        }
    }
    

    func testReceiptModelFetch() {
        setUpAddReceipt()
        
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
        setUpAddReceipt()
        
        //then
        do{
            if #available(iOS 10.0, *) {
                let request: NSFetchRequest<Listio.Item> = Listio.Item.fetchRequest()
                let result = try dataProvider.dataStack.mainContext.fetch(request)
                XCTAssertNotNil(result)
            } else {
                XCTAssertTrue(true)
            }
        } catch let error as NSError {
            XCTFail("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
}
