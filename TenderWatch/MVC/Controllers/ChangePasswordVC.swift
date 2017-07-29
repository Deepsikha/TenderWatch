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
        self.txtNewPassword.text = ""
        self.txtOldPassword.text = ""
        self.txtConfirmPassword.text = ""
    }
    
    override func viewDidLayoutSubviews() {
        self.chnge.layer.cornerRadius = self.chnge.frame.height / 2
    }
    
    //MARK:- TextField Delegate
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
    
    //MARK:- IBActions
    @IBAction func changePass(_ sender: Any) {
        if (USER?.authenticationToken != nil) {
            
            let param = ["oldPassword" :  (txtOldPassword.text)!, "newPassword" :  (txtNewPassword.text)!]
            
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(USER!.authenticationToken!)",
                "Accept": "application/json"
            ]
            if !((self.txtOldPassword.text?.isEmpty)!) {
                if !((self.txtNewPassword.text?.isEmpty)!) && (self.txtNewPassword.text! == self.txtConfirmPassword.text) && (isValidPassword(strPassword: self.txtNewPassword.text!)){
                    if isNetworkReachable() {
                        self.startActivityIndicator()
                        Alamofire.request(CHANGE_PASSWORD, method: .post, parameters: param, encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: { (resp) in
                            let data = resp.result.value as! NSObject
                            if(data.value(forKey: "message") as! String) != "Old password is wrong!!!" {
                                USER?.password = self.txtNewPassword.text
                                self.txtConfirmPassword.text = ""
                                self.txtNewPassword.text = ""
                                self.txtOldPassword.text = ""
                                MessageManager.showAlert(nil, "Password is Successfully Changed ")
                                self.stopActivityIndicator()
                                let nav = UINavigationController(rootViewController: TenderWatchVC())
                                appDelegate.drawerController.centerViewController = nav
                                appDelegate.drawerController.closeDrawer(animated: true, completion: nil)
                            } else {
                                self.txtConfirmPassword.text = ""
                                self.txtNewPassword.text = ""
                                self.txtOldPassword.text = ""
                                self.txtOldPassword.becomeFirstResponder()
                                MessageManager.showAlert(nil, "Old password is wrong!!!")
                                self.stopActivityIndicator()
                            }
                        })
                    } else {
                        MessageManager.showAlert(nil, "No Internet")
                        self.stopActivityIndicator()
                        
                    }
                } else {
                    if (self.txtNewPassword.text?.isEmpty)! {
                        MessageManager.showAlert(nil, "NewPassword can't Empty")
                    } else if !(self.txtNewPassword.text! == self.txtConfirmPassword.text){
                        MessageManager.showAlert(nil, "Confirm Password can't Match")
                    } else {
                        MessageManager.showAlert(nil, "Enter password with 8 characters which contain at least one alphabet, one number and special character")
                    }
                }
            } else {
                MessageManager.showAlert(nil, "Old Password is required")
            }
        }
    }
    
    @IBAction func handleBtnBack(_ sender: Any) {
        appDelegate.drawerController.toggleDrawerSide(.left, animated: true, completion: nil)
    }
    
    //    @IBAction func bck(_ sender: Any) {
    //        self.navigationController?.popViewController(animated: true)
    //    }
    
}
