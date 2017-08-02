//
//  TenderDetail.swift
//  TenderWatch
//
//  Created by devloper65 on 7/27/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit
import ObjectMapper

class TenderDetail: NSObject, Mappable {
    
    var id: String?
    var address : String?
    var category : Category?
    var contactNo : String?
    var country : Country?
    var createdAt: String?
    var desc: String?
    var email : String?
    var exp : String?
    var isActive: String?
    var landlineNo : String?
    var tenderName : String?
    var tenderPhoto : String?
    var tenderUploader: User?
    var favorite: [String]?
    var subscriber: User?
    var amendRead: [String]?
    var readby: [String]?
    var interested: [String]?
    
    required init?(map: Map) {
        super.init()
        mapping(map:map)
    }
    
    func mapping(map: Map) {
        id              <- map["_id"]
        address         <- map["address"]
        category        <- map["category"]
        contactNo       <- map["contactNo"]
        country         <- map["country"]
        createdAt       <- map["createdAt"]
        desc            <- map["description"]
        email           <- map["email"]
        exp             <- map["expiryDate"]
        isActive        <- map["isActive"]
        landlineNo      <- map["landlineNo"]
        tenderName      <- map["tenderName"]
        tenderPhoto     <- map["tenderPhoto"]
        tenderUploader  <- map["tenderUploader"]
        favorite        <- map["favorite"]
        subscriber      <- map["subscriber"]
        amendRead       <- map["amendRead"]
        readby          <- map["readby"]
        interested      <- map["interested"]
    }
}
