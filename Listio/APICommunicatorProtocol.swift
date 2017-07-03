//
//  APICommunicatorProtocol.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2017-04-11.
//  Copyright © 2017 Felipe Dias Pereira. All rights reserved.
//

import UIKit

public protocol APICommunicatorProtocol {
    func getReceipt(linkUrl: String,
        _ completion: @escaping (_ error: Error?,
        _ responseJSON: [String: AnyObject]? ) -> Void)
    func getProduct(code: String, _ completion: @escaping (Error?, [String : AnyObject]?) -> Void)
}
