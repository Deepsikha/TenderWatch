//
//  User.swift
//  TenderWatch
//
//  Created by devloper65 on 6/21/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import Foundation
import ObjectMapper

enum RollType : String {
    case contractor = "contractor"
    case client = "client"
}

class User: NSObject,NSCoding, Mappable {
    
    var _id: String?
    var email: String?
    var firstName: String?
    var lastName: String?
    var createdAt: String?
    var profilePhoto: String?
    var role: RollType?
    var isActive: Bool?
    var password: String?
    var authenticationToken: String?
    
    required init?(map: Map) {
        super.init()
        mapping(map: map)
    }
    
    override init() {
        super.init()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init()
        _id = aDecoder.decodeObject(forKey: "_id") as? String
        email = aDecoder.decodeObject(forKey: "email") as? String
        firstName = aDecoder.decodeObject(forKey: "firstName") as? String
        lastName = aDecoder.decodeObject(forKey: "lastName") as? String
        createdAt = aDecoder.decodeObject(forKey: "createdAt") as? String
        profilePhoto = aDecoder.decodeObject(forKey: "profilePhoto") as? String
        role = RollType(rawValue: (aDecoder.decodeObject(forKey: "role") as! String))
//        role = aDecoder.decodeObject(forKey: "role") as? RollType
        isActive = aDecoder.decodeObject(forKey: "isActive") as? Bool
        authenticationToken = aDecoder.decodeObject(forKey: "token") as? String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(_id, forKey: "_id")
        aCoder.encode(email, forKey: "email")
        aCoder.encode(firstName, forKey: "firstName")
        aCoder.encode(lastName, forKey: "lastName")
        aCoder.encode(createdAt, forKey: "createdAt")
        aCoder.encode(profilePhoto, forKey: "profilePhoto")
        aCoder.encode(role?.rawValue, forKey: "role")
        aCoder.encode(isActive, forKey: "isActive")
        aCoder.encode(authenticationToken, forKey: "token")
    }
    
    func mapping(map: Map) {
        _id                     <- map["_id"]
        email                   <- map["email"]
        firstName               <- map["firstName"]
        lastName                <- map["lastName"]
        createdAt               <- map["createdAt"]
        isActive                <- map["isActive"]
        profilePhoto            <- map["profilePhoto"]
        role                    <- (map["role"],EnumTransform<RollType>())
        password                <- map["password"]
    }
}

class signUpUserData: NSObject {
    var email = ""
    var password = ""
    var photo: Data?
    var country = ""
    var contactNo = ""
    var occupation = ""
    var aboutMe = ""
    var role = ""
    
}
