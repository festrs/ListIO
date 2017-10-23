//
//  ExtensionsTest.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2017-04-10.
//  Copyright © 2017 Felipe Dias Pereira. All rights reserved.
//

import XCTest
import JWT

@testable import Prod

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
            let encoded = toEncoded.JWTEncoded(withExpirationDate: date)
            var claims: ClaimSet = try JWT.decode(encoded, algorithm: .hs256(toEncoded.data(using: .utf8)!))
            
            var claimsTest = ClaimSet()
            claimsTest.issuer = "Listio"
            claimsTest.issuedAt = Date()
            claimsTest.expiration = date
            
            let encodedTest = JWT.encode(claims: claims, algorithm: .hs256(toEncoded.data(using: .utf8)!))
            
            XCTAssertEqual(date.timeIntervalSinceReferenceDate.rounded(), (claims.expiration?.timeIntervalSinceReferenceDate)!.rounded())
            XCTAssertEqual(encodedTest, encoded)
        } catch {
            XCTFail("Failed to decode JWT: \(error)")
        }
    }
    
    func testMaskCurrentCurrency() {
        let number:NSNumber = NSNumber(value: 14.0)
        let stringMask = number.maskToCurrency()
        XCTAssertNotNil(number.maskToCurrency())
        //XCTAssertEqual(stringMask, "R$14,00")
    }
    
    func testTrim() {
        let testableString = " felipe "
        let trimString = testableString.trim()
        XCTAssertEqual(trimString, "felipe")
    }
    
    
}
