//
//  InteligenceCore.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2016-06-01.
//  Copyright © 2016 Felipe Dias Pereira. All rights reserved.
//

import Foundation
import CoreData
import StringScore_Swift

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


//Conjunto de items comuns entre as compras porém diferentes entre si

// comparar a lista com as 16 ultimas compras, normalizar as listas de compras (caso tenha o mesmo item duas vezes na lista)
// com a lista normalizada pegar todos os itens comprados das listas, rankear pela quantidade que ele aparece nas listas (listcount)
// montar a lista baseado na media de preços das listas pegando os itens que mais aparecem 

struct MapItem :Equatable{
    var countDocument = 0
    var qtde = 0
    var name = ""
    var vlUnit:Double = 0
    var vlTotal:Double = 0
    
    mutating func addCountQte(_ value: Int){
        qtde += value
    }
    
    func toJson() ->[String : AnyObject]{
        return ["countDocument":countDocument as AnyObject,"qtde":qtde as AnyObject,"name":name as AnyObject,"vlUnit":vlUnit as AnyObject,"vlTotal":vlTotal as AnyObject]
    }
}

func ==(lhs: MapItem, rhs: MapItem) -> Bool {
    let fuzzy1 = lhs.name.trim().score(rhs.name.trim(), fuzziness:1.0)
    return fuzzy1 > 0.45
}


class InteligenceCore {
    
    var coreDataHandler:CoreDataHandler!
    
    init(coreDataHandler:CoreDataHandler){
        self.coreDataHandler = coreDataHandler
    }
    
    func calculate(){
        if let results = coreDataHandler.getAllDocuments() {
            if results.count == 1{
                let items = results.first?.items?.allObjects as! [Item]
                let finalList = removeRedudancyAndSortForCountDoc(items.map({
                    return MapItem(countDocument: 1, qtde: ($0.qtde?.intValue)!, name: $0.descricao!, vlUnit: ($0.vlUnit?.doubleValue)!, vlTotal: $0.vlTotal!.doubleValue)
                }))
                coreDataHandler.saveItemListObj(finalList)
            }
            let values: [Double] = results.map {
                let payment = NSKeyedUnarchiver.unarchiveObject(with: $0.payments!) as! NSDictionary
                return Double(payment["vl_total"] as! String)!
            }
            let mapped: [MapItem] = getAllItens(results)
            // mapped
            let newMapped = removeRedudancyAndSortForCountDoc(mapped)
            let mediumPriceLists = values.reduce(0, +)/Double(values.count)
            let finalList = getFinalListCutForMediumPrice(newMapped, price: mediumPriceLists)
            coreDataHandler.saveItemListObj(finalList)
        }
    }
}

func getAllItens(_ documentList : [Document])->[MapItem]{
    // put all itens in a single array
    let allItems = documentList.flatMap({ d in d.items!}) as! [Item]
    //check if the item is present in more them 1 document, return list of MapItem
    return allItems.map {
        item in
        var countDoc = 0
        for document in documentList{
            for itemDoc:Item in document.items?.allObjects as! [Item]{
                if itemDoc == item{
                    countDoc += 1
                    break;
                }
            }
        }
        return MapItem(countDocument: countDoc, qtde: (item.qtde?.intValue)!, name: item.descricao!, vlUnit: (item.vlUnit?.doubleValue)!, vlTotal: item.vlTotal!.doubleValue)
    }
}


func removeRedudancyAndSortForCountDoc(_ mappedList: [MapItem])->[MapItem]{
    var newMapped = mappedList.reduce([MapItem]()) {
        a, item in
        var b = [MapItem]()
        var aux = a
        if !a.contains(where: {$0 == item}){
            b.append(item)
        }else{
            let index = a.index(where: {$0 == item})!
            var item2 = a[index]
            item2.addCountQte(item.qtde)
            aux.remove(at: index)
            aux.insert(item2, at: index)
        }
        b.append(contentsOf: aux)
        return b
    }
    newMapped = newMapped.sorted(by: { (a, b) -> Bool in
        a.countDocument < b.countDocument
    })
    return newMapped
}



func getFinalListCutForMediumPrice(_ mappedList:[MapItem], price:Double) -> [MapItem]{
    var totalPrice = 0.0
    var finalList = [MapItem]()
    var listCopy = mappedList
    while totalPrice < price {
        if (listCopy.last?.countDocument >= 2){
            var item = listCopy.popLast()!
            if item.qtde >= item.countDocument{
                item.qtde = item.qtde / item.countDocument
            }
            if item.qtde != 0{
                item.vlTotal = Double((item.qtde)) * (item.vlUnit)
            }
            totalPrice += item.vlTotal
            finalList.append(item)
        }else{
            
            // sort itens that not appear in more then 1 Document
            var item = listCopy.remove(at: Int(arc4random_uniform(UInt32(listCopy.count)))) // TODO escolha do item tem que levar em conta o preço
            if item.qtde >= item.countDocument{
                item.qtde = item.qtde / item.countDocument
            }
            // testar se a quantidade for zero. soma o valor total
            if item.qtde != 0{
                item.vlTotal = Double((item.qtde)) * (item.vlUnit)
            }
            totalPrice += item.vlTotal
            finalList.append(item)
        }
    }
    return finalList
}


