//
//  Categoty.swift
//  TenderWatch
//
//  Created by lanetteam on 29/06/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import Foundation
import ObjectMapper




//class MappingDictionary: NSObject
//{
//    var countryName : [Category] = []
//
//
//}
class Category: NSObject,Mappable {
    
    var categoryId : String?
    var categoryName: String?
    var isSelected : Bool?
    
    required init?(map: Map)
    {
        super.init()
        mapping(map:map)
    }
    func mapping(map: Map)
    {
        categoryId <- map["_id"]
        categoryName <- map["categoryName"]
        isSelected = false
    }
}
