//
//  ForgotPasswordVC.swift
//  TenderWatch
//
//  Created by Developer88 on 6/21/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit
import Alamofire
import IQKeyboardManager

class ChangePasswordVC: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var chnge: UIButton!
    @IBOutlet var btnBack: UIButton!
    
    @IBOutlet weak var txtOldPassword: UITextField!
    @IBOutlet weak var txtNewPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    @IBOutlet weak var lblName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IQKeyboardManager.shared().previousNextDisplayMode = .alwaysHide

        txtOldPassword.delegate = self
        txtNewPassword.delegate = self
        txtConfirmPassword.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        self.chnge.layer.cornerRadius = self.chnge.frame.height / 2
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtOldPassword{
            txtOldPassword.resignFirstResponder()
            txtNewPassword.becomeFirstResponder()
            
        }else if textField == txtNewPassword{
          txtNewPassword.resignFirstResponder()
          txtConfirmPassword.becomeFirstResponder()
        }else{
          txtConfirmPassword.resignFirstResponder()
        }
        return true
    }
    
    @IBAction func changePass(_ sender: Any) {
        //        let url = NSURL(string: "http://192.168.200.22:4040/api/users/changePassword/59479c85285962203c3121ad") //Remember to put ATS exception if the URL is not https
        //        let request = NSMutableURLRequest(url: url! as URL)
        //        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        //        request.addValue("Bearer " + AppDelegate.apiToken, forHTTPHeaderField: "Authorization")//Optional
        //        request.httpMethod = "PUT"
        //        let session = URLSession(configuration:URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
        //        let data = jsonData
        //        request.httpBody = data
        //
        //        let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
        //
        //            if error != nil {
        //
        //                //handle error
        //            }
        //            else {
        //
        //                let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
        //                print("Parsed JSON: '\(String(describing: jsonStr))'")
        //            }
        //        }
        //        dataTask.resume()
        //
        if (USER?.authenticationToken != nil) {
            
            let param = ["oldPassword" :  (txtOldPassword.text)!, "newPassword" :  (txtNewPassword.text)!]
        
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(USER!.authenticationToken!)",
                "Accept": "application/json"
            ]
            if !((self.txtNewPassword.text?.isEmpty)!) && (self.txtNewPassword.text == self.txtConfirmPassword.text) {
                    Alamofire.request(BASE_URL+CHANGE_PASSWORD, method: .post, parameters: param, encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: { (resp) in
                        let data = resp.result.value as! NSObject
                        if(data.value(forKey: "message") as! String) != "Old password is wrong!!!" {
                            USER?.password = self.txtNewPassword.text
                            self.txtConfirmPassword.text = ""
                            self.txtNewPassword.text = ""
                            self.txtOldPassword.text = ""
                            MessageManager.showAlert(nil, "Password is Successfully Changed ")
                            let nav = UINavigationController(rootViewController: TenderWatchVC())
                            appDelegate.drawerController.centerViewController = nav
                            appDelegate.drawerController.closeDrawer(animated: true, completion: nil)
                        } else {
                            self.txtConfirmPassword.text = ""
                            self.txtNewPassword.text = ""
                            self.txtOldPassword.text = ""
                            self.txtOldPassword.becomeFirstResponder()
                            MessageManager.showAlert(nil, "Old password is wrong!!!")
                        }
                    })
            }
        } else {
            MessageManager.showAlert(nil, "Old Password is required")
        }
    }
    
    @IBAction func handleBtnBack(_ sender: Any) {
        appDelegate.drawerController.toggleDrawerSide(.left, animated: true, completion: nil)
    }
    
//    @IBAction func bck(_ sender: Any) {
//        self.navigationController?.popViewController(animated: true)
//    }
    
}
