//
//  RulesVC.swift
//  TestApp
//
//  Created by Developer88 on 6/19/17.
//  Copyright © 2017 Developer88. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

class RulesVC: UIViewController {
    
    @IBOutlet weak var btnChk: UIButton!
    @IBOutlet var btnBack: UIButton!
    @IBOutlet weak var btnSignUp: UIButton!
    
    let checkedImage = UIImage(named: "chaboxcheked")! as UIImage
    let uncheckedImage = UIImage(named: "chabox")! as UIImage
    var isChecked: Bool = false
    var parameters : [String : Any]!
    var user: User!
    var window: UIWindow!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.btnSignUp.cornerRedius()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- IBActions
    @IBAction func handleBtnChk(_ sender: Any) {
        if(isChecked == true) {
            self.btnChk.setImage(uncheckedImage, for: .normal)
            self.isChecked = !isChecked
            
        } else {
            self.btnChk.setImage(checkedImage, for: .normal)
            self.isChecked = !isChecked
        }
    }
    
    @IBAction func handleBtnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func handleBtnSignUp(_ sender: Any) {
        if (isChecked) {
            self.register()
        }
    }
    
    //MARK:- Custom Method
    func register() {
        
        if (appDelegate.isClient)! {
            self.parameters = ["email" : signUpUser.email,
                               "password" : signUpUser.password,
                               "country": signUpUser.country,
                               "contactNo": signUpUser.contactNo,
                               "occupation": signUpUser.occupation,
                               "aboutMe": signUpUser.aboutMe,
                               "role" : "client",
                               "deviceId": appDelegate.token!] as [String : Any]
        } else {
            self.parameters = ["email" :  signUpUser.email,
                               "password" : signUpUser.password,
                               "country": signUpUser.country,
                               "contactNo": signUpUser.contactNo,
                               "occupation": signUpUser.occupation,
                               "aboutMe": signUpUser.aboutMe,
                               "role" : "contractor",
                               "selections": signUpUser.selections,
                               "subscribe": signUpUser.subscribe,
                               "deviceId": appDelegate.token!] as [String : Any]
        }
        
        if isNetworkReachable() {
            self.btnSignUp.isEnabled = false
            self.startActivityIndicator()
            Alamofire.upload(multipartFormData: { multipartFormData in
                if !(signUpUser.photo.isEmpty)
                {
                    let dated :NSDate = NSDate()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyyMMddHHmmssSSS"
                    dateFormatter.timeZone = NSTimeZone(name: "GMT")! as TimeZone
                    
                    let imgname = (dateFormatter.string(from: dated as Date)).appending(String(0) + ".jpg")
                    
                    multipartFormData.append(signUpUser.photo, withName: "image",fileName: imgname, mimeType: "image/jpeg")
                }
                for (key, value) in self.parameters {
                    
                    if let stringValue = value as? String {
                        multipartFormData.append(stringValue.data(using: String.Encoding.utf8)!, withName: key)
                    }
                    else if let dictionaryValue = value as? [String : Any] {
                        let data = try? JSONSerialization.data(withJSONObject: dictionaryValue, options: JSONSerialization.WritingOptions.prettyPrinted)
                        multipartFormData.append(data!, withName: key)
                    }
                }
            },
                             to: SIGNUP)
            { (result) in
                switch result {
                case .success(let upload, _, _):
                    
                    upload.uploadProgress(closure: { (progress) in
                        print("Upload Progress: \(progress.fractionCompleted)")
                    })
                    
                    upload.responseJSON { resp in
                        if (resp.result.value != nil) {
                            print(resp.result.value!)
                            if ((resp.result.value as! NSDictionary).allKeys.contains(where: { (a) -> Bool in
                                if (a as! String) == "error" {
                                    return true
                                } else {
                                    return false
                                }
                            })) {
                                let err = (resp.result.value as! NSObject).value(forKey: "error") as! String
                                MessageManager.showAlert(nil, "\(err)")
                                self.stopActivityIndicator()
                                self.btnSignUp.isEnabled = true
                            } else {
                                self.btnSignUp.isEnabled = true
                                self.stopActivityIndicator()
                                let data = (resp.result.value as! NSObject).value(forKey: "user")!
                                let user:User? = Mapper<User>().map(JSON: data as! [String : Any])!
                                let token = (resp.result.value as! NSObject).value(forKey: "token")!
                                user?.authenticationToken = token as? String
                                UserManager.shared.user = user
                                USER = user
                                if USER?.role == RollType.client {
                                    appDelegate.setHomeViewController()
                                } else {
                                    if USER?.subscribe == subscriptionType.free {
                                        appDelegate.setHomeViewController()
                                    } else {
                                        self.navigationController?.pushViewController(PaymentVC(), animated: true)
                                    }
                                }
                                self.store()
                            }
                        }
                    }
                    
                case .failure(let encodingError):
                    print(encodingError)
                }
            }
        } else {
            MessageManager.showAlert(nil, "No Internet")
            self.btnSignUp.isEnabled = true
            self.stopActivityIndicator()
        }        
    }
    
    func store() {
        if !signUpUser.email.isEmpty && !signUpUser.password.isEmpty {
            let passwordItem = KeychainPasswordItem(service: KeychainConfig.service, account: signUpUser.email, accessGroup: KeychainConfig.accessGroup)
            do {
                try passwordItem.savePassword(signUpUser.password)
            } catch {
                fatalError("Error updating keychain - \(error)")
            }
        } else {
            return
        }
    }
}
