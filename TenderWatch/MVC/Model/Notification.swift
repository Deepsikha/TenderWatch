//
//  Notification.swift
//  TenderWatch
//
//  Created by devloper65 on 8/4/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit
import ObjectMapper

class NotificationUser: NSObject, Mappable {
    
    var id: String?
    var user: User?
    var sender: User?
    var tender: TenderDetail?
    var message: String?
    var createdAt: String?
    var type: String?
    var read: Bool?

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
