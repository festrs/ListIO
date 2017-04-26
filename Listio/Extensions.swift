//
//  Extensions.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2016-06-03.
//  Copyright © 2016 Felipe Dias Pereira. All rights reserved.
//

import UIKit
import JWT

extension NSNumber {
    func toMaskReais() -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: self)
    }
    func maskToCurrency() ->String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.currencyAccounting
        return formatter.string(from: self)
    }
}

extension String
{
    func trim() -> String
    {
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    func removeSpaces() -> String
    {
        return self.replacingOccurrences(of: " ", with: "")
    }
    
    func JWTEncoded(withExpirationDate date: Date) -> String {
        var claims = ClaimSet()
        claims.issuer = "Listio"
        claims.issuedAt = Date()
        claims.expiration = date
        
        return JWT.encode(claims: claims, algorithm: .hs256(self.data(using: .utf8)!))
    }
    
}

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
