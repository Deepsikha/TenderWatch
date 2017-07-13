//
//  APIManager.swift
//  TenderWatch
//
//  Created by lanetteam on 27/06/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit
import Alamofire

typealias SuccessHandler = (_ finish: Bool,_ result: DataResponse<Any>) -> ()
typealias FailureHandler = ( _ error: String) ->()
private let manager = NetworkReachabilityManager(host: "www.google.com")



class APIManager {
    class var shared: APIManager {
        struct Static {
            static let instance = APIManager()
        }
        return Static.instance
    }
    
    func requestForPOST(url: String,isTokenEmbeded: Bool,params: Parameters, successHandler: @escaping SuccessHandler, failureHandler: @escaping FailureHandler){
        
        guard isNetworkReachable() else {
            failureHandler("No Internet Connection")
            return
        }
        var header: HTTPHeaders?
        if isTokenEmbeded {
            guard UserManager.shared.user?.authenticationToken != nil else {
                failureHandler("Token Not Found")
                return
            }
            header = [
                "Authorization": "Bearer \(UserManager.shared.user!.authenticationToken!)",
                "Accept": "application/json"
            ]
        }
        callRequestedAPI(url: url, method: .post, headers: header, params: params, successHandler: successHandler, failureHandler: failureHandler)
    }
    
    func requestForGET(url: String,isTokenEmbeded: Bool,successHandler: @escaping SuccessHandler, failureHandler: @escaping FailureHandler){
        
        guard isNetworkReachable() else {
            failureHandler("No Internet Connection")
            return
        }
        var header: HTTPHeaders?
        if isTokenEmbeded {
            guard UserManager.shared.user?.authenticationToken != nil else {
                failureHandler("Token Not Found")
                return
            }
            header = [
                "Authorization": "Bearer \(UserManager.shared.user!.authenticationToken!)",
                "Accept": "application/json"
            ]
        }
        callRequestedAPI(url: url, method: .get, headers: header, params: nil, successHandler: successHandler, failureHandler: failureHandler)
    }
    
    
    
    func callRequestedAPI(url: String,method: HTTPMethod, headers: HTTPHeaders?,params: Parameters?, successHandler: @escaping SuccessHandler, failureHandler: @escaping FailureHandler) {
        
        Alamofire.request(BASE_URL+url, method: method, parameters:params , encoding: JSONEncoding.default, headers: headers).responseJSON { (res) in
            
            guard res.error == nil else {
                failureHandler(res.error!.localizedDescription)
                return
            }
            if res.response?.statusCode == 200
            {
                successHandler(true,res)
            }
            else{
                var errorMsg: String
                if (res.response?.statusCode) != nil
                {
                    if (res.response?.statusCode == 400) {
                        errorMsg = "Bad Request"
                    } else if (res.response?.statusCode == 401) {
                        errorMsg = "Invalid Credentials"
                    } else if (res.response?.statusCode == 404) {
                        errorMsg = "Not Found!!!"
                    } else {
                        errorMsg = "\(res.response!.statusCode)"
                    }
                }
                else {
                    errorMsg = "Unknown Error"
                }
                failureHandler(errorMsg)
            }
        }
    }
    
}//Class

func isNetworkReachable() -> Bool {
    return manager?.isReachable ?? false
}
