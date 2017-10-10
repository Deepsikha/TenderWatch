//
//  Services.swift
//  TenderWatch
//
//  Created by devloper65 on 10/9/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit
import ObjectMapper

class Services: NSObject, Mappable {
    
    var id: String?
    var categoryId: [String]?
    var userId: String?
    var countryId: String?
    var createdAt: String?
    
    required init?(map: Map)
    {
        super.init()
        mapping(map:map)
    }
    func mapping(map: Map)
    {
        id <- map["_id"]
        categoryId <- map["categoryId"]
        userId <- map["userId"]
        countryId <- map["countryId"]
        createdAt <- map["createdAt"]
    }
}
