//
//  UserManager.swift
//  TenderWatch
//
//  Created by lanetteam on 27/06/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

let kUser = "kUser"
var signUpUser = signUpUserData()
var USER = UserManager.shared.user

class UserManager {
    class var shared: UserManager {
        struct Static {
            static let instance = UserManager()
        }
        return Static.instance
    }
    var user: User? {
        set(newUser) {
            guard newUser != nil else {
                UserDefaults.standard.removeObject(forKey: kUser)
                UserDefaults.standard.synchronize()
                return
            }
            let encodedData = NSKeyedArchiver.archivedData(withRootObject: newUser!)
            UserDefaults.standard.set(encodedData, forKey: kUser)
            UserDefaults.standard.synchronize()
        }
        get {
            if let data = UserDefaults.standard.data(forKey: kUser),
                let user = NSKeyedUnarchiver.unarchiveObject(with: data) as? User {
                return user
            }
            return nil
        }
    }
    
    func signInUser(with params: Parameters,successHandler: @escaping (User?) -> (), failureHandler: @escaping FailureHandler) {
        
        APIManager.shared.requestForPOST(url: LOGIN, isTokenEmbeded: false, params: params, successHandler: { (finish, response) in
            if response.result.value != nil
            {
                print(response.result.value!)
                let data = (response.result.value as! NSObject).value(forKey: "user")!
                let user:User? = Mapper<User>().map(JSON: data as! [String : Any])
                let token = (response.result.value as! NSObject).value(forKey: "token")!
                user?.authenticationToken = token as? String
                self.user = user
                USER = user
                successHandler(user)
            }
            
        }) { (errorMessage) in
            failureHandler(errorMessage)
        }
    }
    
    func logoutCurrentUser() {
        
        UserDefaults.standard.removeObject(forKey: kUser)
        UserDefaults.standard.synchronize()
        self.user = nil
        USER = nil
        appDelegate.setUpRootVc()
    }
    
}
