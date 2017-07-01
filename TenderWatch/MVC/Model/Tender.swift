//
//  Tender.swift
//  TenderWatch
//
//  Created by Developer88 on 6/30/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit
import ObjectMapper

class Tender: NSObject, Mappable {

    var country : String?
    var category : String?
    var tenderName : String?
    var desc: String?
    var email : String?
    var landlineNo : String?
    var contactNo : String?
    var address : String?
    var exp : String?
    var tenderPhoto : String?
    
        required init?(map: Map) {
            super.init()
            mapping(map:map)
        }
        func mapping(map: Map) {
            country         <- map["country"]
            category        <- map["category"]
            tenderName      <- map["tenderName"]
            desc            <- map["description"]
            email           <- map["email"]
            landlineNo      <- map["landlineNo"]
            contactNo       <- map["contactNo"]
            address         <- map["address"]
            exp             <- map["expiryDate"]
            tenderPhoto     <- map["tenderPhoto"]
        }

    
}
