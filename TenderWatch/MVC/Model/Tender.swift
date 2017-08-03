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
    
    var id: String?
    var address : String?
    var category : String?
    var contactNo : String?
    var country : String?
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
    var subscriber: String?
    var readby: [String]?
    var amendRead:[String]?
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
        readby          <- map["readby"]
        amendRead       <- map["amendRead"]
        interested      <- map["interested"]
    }
}

class UploadTender: NSObject {
    
    var cId: String = "" //for country
    var ctId: String = "" //for categoty
    var tenderTitle = ""
    var desc = ""
    var photo = Data()
    var email = ""
    var contactNo = ""
    var landLineNo = ""
    var address = ""
    
    override init() {
        super.init()
    }
}
