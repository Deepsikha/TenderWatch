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
    
    static var arrCountry: [String] = []
    static var arrCategory: [String] = []
    
    var user: User!
    
    var window: UIWindow!
    @IBOutlet weak var btnChk: UIButton!
    @IBOutlet var btnBack: UIButton!
  
    let checkedImage = UIImage(named: "chaboxcheked")! as UIImage
    let uncheckedImage = UIImage(named: "chabox")! as UIImage
    var isChecked: Bool = false
    var parameters : [String : Any]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
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
    
    @IBAction func nxt(_ sender: Any) {
        if (isChecked) {
            self.register()
        }
    }
    
    //MARK:-email password firstName lastName role profilePhoto
//    email, firstName, lastName, password, profilePhoto, country, category, contactNo, occupation, aboutMe, role
    func register() {
        let arrCountry = RulesVC.arrCountry.joined(separator: ",")
        let arrCategory = RulesVC.arrCategory.joined(separator: ",")
        
        if (appDelegate.isClient)! {
            self.parameters = ["email" : signUpUser.email,
                              "password" : signUpUser.password,
                              "country": signUpUser.country,
                              "contactNo": signUpUser.contactNo,
                              "occupation": signUpUser.occupation,
                              "aboutMe": signUpUser.aboutMe,
                              "role" : signUpUser.role] as [String : Any]
        } else {
            self.parameters = ["email" :  signUpUser.email,
                              "password" : signUpUser.password,
                              "country": signUpUser.country,
                              "contactNo": signUpUser.contactNo,
                              "occupation": signUpUser.occupation,
                              "aboutMe": signUpUser.aboutMe,
                              "role" : signUpUser.role] as [String : Any]
        }
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            if signUpUser.photo != nil
            {
                let dated :NSDate = NSDate()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyyMMddHHmmssSSS"
                dateFormatter.timeZone = NSTimeZone(name: "GMT")! as TimeZone
                
                let imgname = (dateFormatter.string(from: dated as Date)).appending(String(0) + ".jpg")
            
            multipartFormData.append(signUpUser.photo!, withName: "fileset",fileName: imgname, mimeType: "image/jpg")
            }
            for (key, value) in self.parameters {
                multipartFormData.append((value as AnyObject).data(using: UInt(String.Encoding.utf8.hashValue))!, withName: key)
            }
        },
                         to:"http://192.168.200.22:4040/api/auth/register")
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                
                upload.responseJSON { resp in
                    if (resp.result.value != nil) {
                        print(resp.result.value!)
                        if (((resp.result.value as! NSDictionary).allKeys[0] as! String) == "error") {
                            MessageManager.showAlert(nil, "Invalid Credentials")
                        } else {
                            
                            //Set User remaining
                           // if (USER?.authenticationToken != nil) {
                            
                                let data = (resp.result.value as! NSObject).value(forKey: "user")!
                            USER = Mapper<User>().map(JSON: data as! [String : Any])!
                            let token = (resp.result.value as! NSObject).value(forKey: "token")!
                            USER?.authenticationToken = token as? String
                            appDelegate.setHomeViewController()
//                             self.navigationController?.pushViewController(TenderWatchVC(), animated: true)
                           // self.user = user
                           // USER = user

                            
                           // }
                        }
                }
                }
                
            case .failure(let encodingError):
                print(encodingError)
            }
        }
    }
}
