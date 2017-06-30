//
//  Select.swift
//  TenderWatch
//
//  Created by devloper65 on 6/29/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit
import ObjectMapper

var addCC = [addCountryObj]()

class Select: NSObject, Mappable {

    var selections = [Selections]()
    required init?(map: Map) {
        super.init()
        mapping(map:map)
    }
    override init() {
        super.init()
    }
    
    func mapping(map: Map) {
        selections <- map["selections"]
    }
}

class Selections: NSObject, Mappable {
    
    var countryId : String?
    var categoryId: [String] = []
    
    required init?(map: Map) {
        super.init()
        mapping(map:map)
    }
    
    override init() {
        super.init()
    }
    
    func mapping(map: Map) {
        countryId <- map["countryId"]
        categoryId <- map["categoryId"]
    }
}

class addCountryObj: NSObject {
    var countryId: String = ""
    var categoryId: [String] = []
}
