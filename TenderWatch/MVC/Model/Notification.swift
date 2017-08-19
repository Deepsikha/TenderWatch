//
//  Notification.swift
//  TenderWatch
//
//  Created by devloper65 on 8/4/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit
import ObjectMapper

class Notification: NSObject, Mappable {
    
    var id: String?
    var user: User?
    var sender: User?
    var tender: TenderDetail?
    var message: String?
    var createdAt: String?
    var type: String?
    var read: Bool?
    
//    "sender": {
//    "_id": "5981bc34b5fb605c7406d446",
//    "email": "support@tenderwatch.com",
//    "role": "support",
//    "createdAt": "2017-08-04T10:54:26.052Z",
//    "isActive": true,
//    "profilePhoto": "no image"
//    }
    
    required init?(map: Map) {
        super.init()
        mapping(map:map)
    }
    
    func mapping(map: Map) {
        id          <- map["_id"]
        user        <- map["user"]
        sender      <- map["sender"]
        tender      <- map["tender"]
        message     <- map["message"]
        createdAt   <- map["createdAt"]
        read        <- map["read"]
    }
}
