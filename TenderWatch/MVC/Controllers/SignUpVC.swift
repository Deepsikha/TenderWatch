//
//  SignUpVC.swift
//  TenderWatch
//
//  Created by lanetteam on 19/06/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit

class SignUpVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var vwEmail: UIView!
    @IBOutlet weak var vwPassword: UIView!
    @IBOutlet weak var vwConfirmPassword: UIView!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet var btnSignUpFacebook: UIButton!
    @IBOutlet var btnSignUpGmail: UIButton!
    @IBOutlet var btnBack: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.txtEmail.delegate = self
        self.txtConfirmPassword.delegate = self
        self.txtPassword.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillLayoutSubviews() {
        self.btnSignUp.cornerRedius()
    }
    
    //MARK:- TextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == self.txtEmail) {
            if (textField.text != "") {
                textField.resignFirstResponder()
                self.txtPassword.becomeFirstResponder()
            } else {
                MessageManager.showAlert(nil, "Enter Email")
            }
        } else if (textField == self.txtPassword) {
            if(textField.text != "") {
                textField.resignFirstResponder()
                self.txtConfirmPassword.becomeFirstResponder()
            } else {
                MessageManager.showAlert(nil, "Enter Password")
            }
        } else {
            if(textField.text != "") {
                textField.resignFirstResponder()
                self.btnSignUp.becomeFirstResponder()
            } else {
                MessageManager.showAlert(nil, "Enter Confirm Password")
            }
        }
        return true
    }
    
    //MARK:- IBActions
    @IBAction func handleBtnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSignUpClick(_ sender: Any) {
        if (self.txtEmail.text?.isEmpty)! && (self.txtPassword.text?.isEmpty)! && (self.txtConfirmPassword.text?.isEmpty)! {
            MessageManager.showAlert(nil, "Email & Password required!")
        } else {
            if isValidEmail(strEmail: self.txtEmail.text!) {
                if (self.txtPassword.text != "") && (self.txtPassword.text == self.txtConfirmPassword.text) {
                    
                    signUpUser.email = self.txtEmail.text!
                    signUpUser.password = self.txtPassword.text!
                    self.navigationController?.pushViewController(SignUpVC2(), animated: true)
                } else {
                    MessageManager.showAlert(nil, "Password can't Match or Empty!")
                }
            } else {
                MessageManager.showAlert(nil, "Invalid Email")
            }
        }
    }
    
    @IBAction func handleBtnSignUpFacebook(_ sender: Any) {
    }
    
    @IBAction func handleBtnSignUpGmail(_ sender: Any) {
    }
}
