//
//  Extensions.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2016-06-03.
//  Copyright © 2016 Felipe Dias Pereira. All rights reserved.
//

import UIKit

// MARK: URL Base
let urlBase:String = "http://nfc-e-server.herokuapp.com"

// MARK: EndPoints
let endPointAllProducts:String = "/api/v1/qrdata"

let monthsName: [Int:String] = [1:"JAN",2:"FEV",3:"MAR",4:"ABR",5:"MAIO",6:"JUN",7:"JUL",8:"AGO",9:"SET",10:"OUT",11:"NOV",12:"DEZ"]

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static func randomColor() -> UIColor {
        let r = CGFloat.random()
        let g = CGFloat.random()
        let b = CGFloat.random()
        
        return UIColor(red: r, green: g, blue: b, alpha: 2.5)
    }
}

extension Date {
    func getComponent(_ component:NSCalendar.Unit) -> Int?{
        if
            let cal: Calendar = Calendar.current{
            return (cal as NSCalendar).component(component, from: self)
        } else {
            return nil
        }
    }
}

extension NSNumber {
    func toMaskReais() ->String?{
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: self)
    }
    func maskToCurrency() ->String?{
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.currencyAccounting
        return formatter.string(from: self)
    }
}

extension Int
{
    static func random(_ range: Range<Int> ) -> Int
    {
        var offset = 0
        
        if range.lowerBound < 0   // allow negative ranges
        {
            offset = abs(range.lowerBound)
        }
        
        let mini = UInt32(range.lowerBound + offset)
        let maxi = UInt32(range.upperBound   + offset)
        
        return Int(mini + arc4random_uniform(maxi - mini)) - offset
    }
}

func flatten<T>(_ a: [[T]]) -> [T] {
    return a.reduce([]) {
        res, ca in
        return res + ca
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
}

public protocol Groupable {
    func sameGroupAs(_ otherPerson: Self) -> Bool
}


extension Collection where Self.Iterator.Element: Groupable {
    public func group() -> [[Self.Iterator.Element]] {
        return self.groupBy { $0.sameGroupAs($1) }
    }
    
}

extension Collection where Self.Iterator.Element: Comparable {
    public func uniquelyGroupBy(_ grouper: (Self.Iterator.Element, Self.Iterator.Element) -> Bool) -> [[Self.Iterator.Element]] {
        let sorted = self.sorted()
        return sorted.groupBy(grouper)
    }
    
}

extension Collection {
    public typealias ItemType = Self.Iterator.Element
    public typealias Grouper = (ItemType, ItemType) -> Bool
    
    public func groupBy(_ grouper: Grouper) -> [[ItemType]] {
        var result : Array<Array<ItemType>> = []
        
        var previousItem: ItemType?
        var group = [ItemType]()
        
        for item in self {
            // Current item will be the next item
            defer {previousItem = item}
            
            // Check if it's the first item
            guard let previous = previousItem else {
                group.append(item)
                continue
            }
            
            if grouper(previous, item) {
                // Item in the same group
                group.append(item)
            } else {
                // New group
                result.append(group)
                group = [ItemType]()
                group.append(item)
            }
        }
        
        result.append(group)
        
        return result
    }
    
}

extension Sequence where Iterator.Element: Equatable {
    func containsObject(_ val: Self.Iterator.Element?) -> Bool {
        if val != nil {
            for item in self {
                if item == val {
                    return true
                }
            }
        }
        return false
    }
}

extension Sequence where Iterator.Element: AnyObject {
    func containsObject(_ obj: Self.Iterator.Element?) -> Bool {
        if obj != nil {
            for item in self {
                if item === obj {
                    return true
                }
            }
        }
        return false
    }
}

public extension Sequence {
    /// Categorises elements of self into a dictionary, with the keys given by keyFunc
    func categorise<U : Hashable>(_ keyFunc: (Iterator.Element) -> U) -> [U:[Iterator.Element]] {
        var dict: [U:[Iterator.Element]] = [:]
        for el in self {
            let key = keyFunc(el)
            if case nil = dict[key]?.append(el) { dict[key] = [el] }
        }
        return dict
    }
}


extension Date {
    func yearsFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.year, from: date, to: self, options: []).year!
    }
    func monthsFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.month, from: date, to: self, options: []).month!
    }
    func weeksFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.weekOfYear, from: date, to: self, options: []).weekOfYear!
    }
    func daysFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.day, from: date, to: self, options: []).day!
    }
    func hoursFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.hour, from: date, to: self, options: []).hour!
    }
    func minutesFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.minute, from: date, to: self, options: []).minute!
    }
    func secondsFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.second, from: date, to: self, options: []).second!
    }
    func offsetFrom(_ date:Date) -> String {
        if yearsFrom(date)   > 0 { return "\(yearsFrom(date))y"   }
        if monthsFrom(date)  > 0 { return "\(monthsFrom(date))M"  }
        if weeksFrom(date)   > 0 { return "\(weeksFrom(date))w"   }
        if daysFrom(date)    > 0 { return "\(daysFrom(date))d"    }
        if hoursFrom(date)   > 0 { return "\(hoursFrom(date))h"   }
        if minutesFrom(date) > 0 { return "\(minutesFrom(date))m" }
        if secondsFrom(date) > 0 { return "\(secondsFrom(date))s" }
        return ""
    }
}

extension UIView {
    class func loadFromNibNamed(_ nibNamed: String, bundle : Bundle? = nil) -> UIView? {
        return UINib(
            nibName: nibNamed,
            bundle: bundle
            ).instantiate(withOwner: nil, options: nil)[0] as? UIView
    }
}
