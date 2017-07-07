//
//  Country.swift
//  TenderWatch
//
//  Created by lanetteam on 29/06/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import Foundation
import ObjectMapper

class Country: NSObject,Mappable {
    
    var countryCode: String?
    var countryId : String?
    var countryName : String?
    var isoCode: String?
    
    required init?(map: Map)
    {
        super.init()
        mapping(map:map)
    }
    
    func mapping(map: Map)
    {
        countryId   <- map["_id"]
        countryName <- map["countryName"]
        countryCode <- map["countryCode"]
        isoCode     <- map["isoCode"]
    }
    
}
