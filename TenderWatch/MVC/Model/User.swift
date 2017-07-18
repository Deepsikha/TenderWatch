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
    
    var authenticationToken: String?
    
    var _id: String?
    var email: String?
    var profilePhoto: String?
    
    var country: String?
    var contactNo: String?
    var occupation: String?
    var aboutMe: String?
    var role: RollType?
    var createdAt: String?
    var isActive: Bool?
    
    var firstName: String?
    var lastName: String?
    var password: String?
    
    required init?(map: Map) {
        super.init()
        mapping(map: map)
    }
    
    override init() {
        super.init()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init()
        authenticationToken = aDecoder.decodeObject(forKey: "token") as? String
        
        _id = aDecoder.decodeObject(forKey: "_id") as? String
        email = aDecoder.decodeObject(forKey: "email") as? String
        profilePhoto = aDecoder.decodeObject(forKey: "profilePhoto") as? String
        country = aDecoder.decodeObject(forKey: "country") as? String
        contactNo = aDecoder.decodeObject(forKey: "contactNo") as? String
        occupation = aDecoder.decodeObject(forKey: "occupation") as? String
        aboutMe = aDecoder.decodeObject(forKey: "aboutMe") as? String
        role = RollType(rawValue: (aDecoder.decodeObject(forKey: "role") as! String))
        createdAt = aDecoder.decodeObject(forKey: "createdAt") as? String
        isActive = aDecoder.decodeObject(forKey: "isActive") as? Bool
        
        firstName = aDecoder.decodeObject(forKey: "firstName") as? String
        lastName = aDecoder.decodeObject(forKey: "lastName") as? String
        //        role = aDecoder.decodeObject(forKey: "role") as? RollType
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(authenticationToken, forKey: "token")
        
        aCoder.encode(_id, forKey: "_id")
        aCoder.encode(email, forKey: "email")
        aCoder.encode(profilePhoto, forKey: "profilePhoto")
        aCoder.encode(country, forKey: "country")
        aCoder.encode(contactNo, forKey: "contactNo")
        aCoder.encode(occupation, forKey: "occupation")
        aCoder.encode(aboutMe, forKey: "aboutMe")
        aCoder.encode(role?.rawValue, forKey: "role")
        aCoder.encode(createdAt, forKey: "createdAt")
        aCoder.encode(isActive, forKey: "isActive")
        
        aCoder.encode(firstName, forKey: "firstName")
        aCoder.encode(lastName, forKey: "lastName")
        
    }
    
    func mapping(map: Map) {
        _id                     <- map["_id"]
        email                   <- map["email"]
        profilePhoto            <- map["profilePhoto"]
        country                 <- map["country"]
        contactNo               <- map["contactNo"]
        occupation              <- map["occupation"]
        aboutMe                 <- map["aboutMe"]
        role                    <- (map["role"],EnumTransform<RollType>())
        createdAt               <- map["createdAt"]
        isActive                <- map["isActive"]
        
        firstName               <- map["firstName"]
        lastName                <- map["lastName"]
        password                <- map["password"]
    }
}

class signUpUserData: NSObject {
    var email = ""
    var password = ""
    var photo = Data()
    var country = ""
    var contactNo = ""
    var occupation = ""
    var aboutMe = ""
    var selections: [String : [String]] = [:]
    
    override init() {
        super.init()
    }    
}
