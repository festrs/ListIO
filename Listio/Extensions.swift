//
//  Extensions.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2016-06-03.
//  Copyright © 2016 Felipe Dias Pereira. All rights reserved.
//

import UIKit
import JWT
import RealmSwift

struct Alerts {
    static let DismissAlert = "Ok"
    static let ErroTitle = "Atenção"
    static let ErrorDoubleReceiptWithSameID = "Nota já cadastrada."
}

extension Results {
    func toArray<T>(ofType: T.Type) -> [T] {
        var array = [T]()
        for i in 0 ..< count {
            if let result = self[i] as? T {
                array.append(result)
            }
        }

        return array
    }
}

extension NSNumber {
    func toMaskReais() -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: self)
    }
    func maskToCurrency() -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.currencyAccounting
        return formatter.string(from: self)
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }

    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

extension String {
    func maskToReais() -> String? {
        if let parseFloat = Float(self) {
            let number = NSNumber(value: parseFloat)
            let formatter = NumberFormatter()
            formatter.numberStyle = NumberFormatter.Style.currency
            formatter.locale = Locale(identifier: "pt_BR")

            return formatter.string(from: number)
        }
        return ""
    }

    func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }

    func removeSpaces() -> String {
        return self.replacingOccurrences(of: " ", with: "")
    }

    func JWTEncoded(withExpirationDate date: Date) -> String {
        var claims = ClaimSet()
        claims.issuer = "Listio"
        claims.issuedAt = Date()
        claims.expiration = date

        return JWT.encode(claims: claims, algorithm: .hs256(self.data(using: .utf8)!))
    }

    var digits: [UInt8] { return characters.flatMap { UInt8(String($0)) } }

    var decimal: Decimal {
        return self.digits.decimal /
            Decimal(pow(10, Double(Formatter.currency.maximumFractionDigits)))
    }
}

extension Sequence where Self.Iterator.Element: Equatable {
    public typealias Element = Self.Iterator.Element

    func freqTuple() -> [(element: Element, count: Int)] {

        let empty: [(Element, Int)] = []

        return reduce(empty) { (accu: [(Element, Int)], element) in
            var accu = accu
            for (index, value) in accu.enumerated() where value.0 == element {
                    accu[index].1 += 1
                    return accu
            }
            return accu + [(element, 1)]
        }
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension NumberFormatter {
    convenience init(numberStyle: Style) {
        self.init()
        self.numberStyle = numberStyle
    }
}
extension Formatter {
    static let currency = NumberFormatter(numberStyle: .currency)
}

extension Collection where Iterator.Element == UInt8 {
    var string: String { return map(String.init).joined() }
    var decimal: Decimal { return Decimal(string: string) ?? 0 }
}
extension Decimal {
    var number: NSDecimalNumber { return NSDecimalNumber(decimal: self) }
}
extension Date {
    func getDateStringShort() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from:self)
    }
}
