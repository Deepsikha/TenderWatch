//
//  APIManager.swift
//  TenderWatch
//
//  Created by lanetteam on 27/06/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit
import Alamofire
import Stripe

typealias SuccessHandler = (_ finish: Bool,_ result: DataResponse<Any>) -> ()
typealias FailureHandler = ( _ error: String) ->()
private let manager = NetworkReachabilityManager(host: "www.google.com")

class NetworkManager {
    static let sharedInstance = NetworkManager()
    let defaultManager: SessionManager = {
        let pathToCert = Bundle.main.path(forResource: "192.168.200.78", ofType: "crt") // Downloaded this certificate and have added to my bundle
        let localCertificate:NSData = NSData(contentsOfFile: pathToCert!)!
        
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            "192.168.200.78": .pinCertificates(
                certificates: [SecCertificateCreateWithData(nil, localCertificate)!],
                validateCertificateChain: true,
                validateHost: true
            ),
            "lanetteam.com": .disableEvaluation
        ]
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        
        return SessionManager(
            configuration: configuration,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
    }()
}

class APIManager: NSObject, STPEphemeralKeyProvider {
    
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
                    if (url == LOGIN) {
                        if (res.response?.statusCode == 400) {
                            errorMsg = "Bad Request"
                        } else if (res.response?.statusCode == 401) {
                            errorMsg = "Invalid Credentials"
                        } else if (res.response?.statusCode == 404) {
                            errorMsg = "Email is not registered "
                        } else {
                            errorMsg = "\(res.response!.statusCode)"
                        }
                    } else {
                        if (res.response?.statusCode == 400) {
                            if (url == G_LOGIN) {
                                errorMsg = "This Gmail Account has not registered in our application"
                            } else {
                                errorMsg = "This Facebook Account has not registered in our application"
                            }
                        } else if (res.response?.statusCode == 401) {
                            errorMsg = "Please check your role"
                        } else {
                            errorMsg = "\(res.response!.statusCode)"
                        }
                    }
                }
                else {
                    errorMsg = "Unknown Error"
                }
                failureHandler(errorMsg)
            }
        }
    }
  
    func completeCharge(_ result: STPPaymentResult, amount: Int, completion: @escaping STPJSONResponseCompletionBlock) {
        
        //Currencry: TZS
        let params: [String: Any] = [
            "source": result.source.stripeID,
            "amount": amount
        ]
        
        Alamofire.request(PAYMENTS+"charges", method: .post, parameters: params, encoding: JSONEncoding.default, headers: ["Authorization" : "Bearer \(UserManager.shared.user!.authenticationToken!)"])
            .validate(statusCode: 200..<300)
            .responseJSON { responseJSON in
                switch responseJSON.result {
                case .success(let json):
                    completion(json as! [String: AnyObject], nil)
                case .failure(let error):
                    print(error)
                    completion(nil, error)
                }
            }
    }
    
    func createCharge(_ token: String, amount: Int, completion: @escaping STPJSONResponseCompletionBlock) {
        
        //Currencry: TZS
        let params: [String: Any] = [
            "source": token,
            "amount": amount
        ]
        
        Alamofire.request(PAYMENTS+"charges", method: .post, parameters: params, encoding: JSONEncoding.default, headers: ["Authorization" : "Bearer \(UserManager.shared.user!.authenticationToken!)"])
            .validate(statusCode: 200..<300)
            .responseJSON { responseJSON in
                switch responseJSON.result {
                case .success(let json):
                    completion(json as! [String: AnyObject], nil)
                case .failure(let error):
                    print(error)
                    completion(nil, error)
                }
        }
    }
    
    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
        Alamofire.request(PAYMENTS+"ephemeral_keys", method: .post, parameters: ["api_version": apiVersion], encoding: JSONEncoding.default, headers: ["Authorization" : "Bearer \(UserManager.shared.user!.authenticationToken!)"])
            .validate(statusCode: 200..<300)
            .responseJSON { responseJSON in
                switch responseJSON.result {
                case .success(let json):
                    completion(json as? [String: AnyObject], nil)
                case .failure(let error):
                    print(error)
                    completion(nil, error)
                }
        }
    }
}//Class

func isNetworkReachable() -> Bool {
    return manager?.isReachable ?? false
}
