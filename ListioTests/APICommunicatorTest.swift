//
//  APICommunicatorTest.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2017-04-17.
//  Copyright © 2017 Felipe Dias Pereira. All rights reserved.
//

import XCTest
@testable import Listio

class APICommunicatorTest: XCTestCase {
    
    var apiCommunicator:APICommunicator!
    
    override func setUp() {
        super.setUp()
        apiCommunicator = APICommunicator()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testApiCommunicatorGetReceipt() {
        let linkUrl = "https://www.sefaz.rs.gov.br/NFCE/NFCE-COM.aspx?chNFe=43160593015006003210651190000448421163150095&nVersao=100&tpAmb=1&dhEmi=323031362d30352d32395432303a35353a30392d30333a3030&vNF=59.22&vICMS=0.00&digVal=7973536f417074336a3054747135614a46593548304b6b5a6535413d&cIdToken=000001&cHashQRCode=F975680E1E08C7A23C78B8FE0A68CFAD6F4C3852"
        
        let asyncExpectation = expectation(description: "getReceipt")
        var result:[String: AnyObject]? = nil
        
        apiCommunicator.getReceipt(linkUrl: linkUrl) { (error, resultJSON) in
            guard error == nil else {
                XCTAssertTrue(false)
                return
            }
            result = resultJSON
            asyncExpectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 60) { (error) in
            XCTAssertNil(error)
            XCTAssertNotNil(result)
        }
    }
}
