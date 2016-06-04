//
//  ListioTests.swift
//  ListioTests
//
//  Created by Felipe Dias Pereira on 2016-05-30.
//  Copyright © 2016 Felipe Dias Pereira. All rights reserved.
//

import XCTest
@testable import Listio

class ListioTests: XCTestCase {
    var core:InteligenceCore!
    
    override func setUp() {
        super.setUp()
        core =  InteligenceCore()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            (self.core.calculate(appDelegate.dataStack.mainContext))
        }
    }
    
}
