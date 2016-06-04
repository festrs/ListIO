//
//  DetailViewController.swift
//  NFC-E-Project
//
//  Created by Felipe Dias Pereira on 2016-02-24.
//  Copyright © 2016 Felipe Dias Pereira. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    //MARK: - Variables
    @IBOutlet weak var qtdTotalLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var itemsTableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    var items: [Item]!
    var payments: [AnyObject]!
    var document: Document!
    
    
    //MARK: - App life
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.setUp()
        // not show empty tableviewcell
        self.itemsTableView.tableFooterView = UIView(frame: CGRect.zero)
        self.itemsTableView.alwaysBounceVertical = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldAutorotate() -> Bool {
        let orientation = UIApplication.sharedApplication().statusBarOrientation
        switch (orientation){
        case .Portrait:
            return false
        case .PortraitUpsideDown:
            return false
        default:
            return true
        }
    }
    
    //MARK: - Setup Labels
    func setUp(){
        self.items = document.items?.allObjects as! [Item]
        
//        let monthName = monthsName[Int(document.mes!.substringWithRange(0, end: 2))!]! as String
//        let splitedString = document.createdAt?.componentsSeparatedByString(" ")
//        let splitedData = (splitedString![0]).componentsSeparatedByString("/")
//        let splitedHour = (splitedString![1]).componentsSeparatedByString(":")
//        self.titleLabel.text = "\(splitedData[0])/\(monthName) \(splitedHour[0]):\(splitedHour[1])"
        
        let payment = NSKeyedUnarchiver.unarchiveObjectWithData(document.payments!) as! NSDictionary
        self.payments = payment["pagmetodos"] as! [AnyObject]
        let total:String = (payment["vl_total"] as! String).stringByReplacingOccurrencesOfString(".", withString: ",")
        self.totalLabel.text = "R$\(total)"
        
        self.qtdTotalLabel.text = "Qtd. Total Itens \(self.items.count.description)"
    }
    
    @IBAction func goToLink(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: self.document.link!)!)
    }
    
    //MARK: - Back Button Pressed
    @IBAction func backButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: - UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
            if section == 1{
                return payments.count
            }
            return items.count
    }
    
    func tableView(tableView: UITableView,
        cellForRowAtIndexPath
        indexPath: NSIndexPath) -> UITableViewCell {
            
            if indexPath.section == 1 {
                let cell = tableView.dequeueReusableCellWithIdentifier("ItemCell", forIndexPath: indexPath)
                
                let payment = payments[indexPath.row]
                
                cell.textLabel!.text = payment["forma_pag"] as? String
                cell.detailTextLabel?.text = payment["valor"] as? String
                
                return cell
            }
            let cell = tableView.dequeueReusableCellWithIdentifier("ItemCell", forIndexPath: indexPath)
            
            let notaItem = items[indexPath.row]
            
            cell.textLabel!.text = notaItem.descricao
            cell.detailTextLabel?.text = notaItem.vlTotal?.description
            
            return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1{
            let cell = tableView.dequeueReusableCellWithIdentifier("HeaderPaymentCell")
            (cell?.viewWithTag(1) as! UILabel).text = "Formas de Pagamento"
            (cell?.viewWithTag(2) as! UILabel).text = "Valor Pago"
            return cell
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("HeaderItemCell")
        (cell?.viewWithTag(1) as! UILabel).text = "Descrição"
        (cell?.viewWithTag(2) as! UILabel).text = "VL. Total R$"
        return cell
    }
    
}
