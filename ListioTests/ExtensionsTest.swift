//
//  ExtensionsTest.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2017-04-10.
//  Copyright © 2017 Felipe Dias Pereira. All rights reserved.
//

import XCTest
import JWT

@testable import Listio

class ExtensionsTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testJWTEncoded() {
        let toEncoded = "encoded"
        let date = Date().addingTimeInterval(30*60)

        do {
            let claims: ClaimSet = try JWT.decode(toEncoded.JWTEncoded(withExpirationDate: date), algorithm: .hs256(toEncoded.data(using: .utf8)!))
            XCTAssertEqual(date.timeIntervalSinceReferenceDate.rounded(), (claims.expiration?.timeIntervalSinceReferenceDate)!.rounded())
        } catch {
            XCTFail("Failed to decode JWT: \(error)")
        }
    }
    
    func testMarkToReais() {
        let number:NSNumber = NSNumber(value: 14.0)
        XCTAssertEqual(number.toMaskReais(), "R$14,00")
    }
    
    func testTrim() {
        let testableString = " felipe "
        XCTAssertEqual(testableString.trim(), "felipe")
    }
    
    
}
