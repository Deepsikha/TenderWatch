//
//  SignInVC.swift
//  Chat_App
//
//  Created by Devloper30 on 19/06/17.
//  Copyright © 2017 LaNet. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import Google

class SignInVC: UIViewController, UITextFieldDelegate, GIDSignInUIDelegate, GIDSignInDelegate {
    
    @IBOutlet var imgAppLogo: UIImageView!
    @IBOutlet var txfEmail: UITextField!
    @IBOutlet var txfPassword: UITextField!
    @IBOutlet var btnSignIn: UIButton!
    @IBOutlet var btnBack: UIButton!
    @IBOutlet weak var btnGmailSignIn: GIDSignInButton!
    
    var user: User!
    var window: UIWindow!
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        
        self.txfEmail.delegate = self
        self.txfPassword.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.btnSignIn.cornerRedius()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Google SignIn Delegate
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            let parameters: Parameters = ["token" : user?.authentication.idToken! as Any,
                                          "role" : signUpUser.role]
            self.Login(G_LOGIN, parameters)
            GIDSignIn.sharedInstance().signOut()
        } else {
            print("\(error.localizedDescription)")
        }
    }
    
    func sign(_ signIn: GIDSignIn!,
              present viewController: UIViewController!) {
        // Present a view that prompts the user to sign in with Google
        self.present(viewController, animated: true, completion: nil)
    }
    
    //MARK:- TextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == self.txfEmail) {
            textField.resignFirstResponder()
            self.txfPassword.becomeFirstResponder()
        } else if(textField == self.txfPassword) {
            textField.resignFirstResponder()
            self.btnSignIn.becomeFirstResponder()
        }
        return true
    }
    
    //MARK:- IBActions
    @IBAction func handleBtnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnHandleGmail(_ sender: UIButton) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func btnHandleFacebook(_ sender: UIButton) {
        GIDSignIn.sharedInstance().signOut()
    }
    
    @IBAction func btnHandleNewAC(_ sender: UIButton) {
        self.navigationController?.pushViewController(SignUpVC(), animated: true)
    }
    
    @IBAction func btnHandleForgot(_ sender: UIButton) {
        self.navigationController?.pushViewController(ForgotPasswordVC(), animated: true)
    }
    
    @IBAction func btnHandleSignIn(_ sender: UIButton) {
        let parameters: Parameters = ["email" : self.txfEmail.text!,
                          "password" : self.txfPassword.text!,
                          "role" : signUpUser.role]
        Login(LOGIN, parameters)
        
    }
    
    func Login(_ url: String,_ param: Parameters) {
        startActivityIndicator()
        UserManager.shared.signInUser(url: url, with: param, successHandler: { (user) in
            print("Logged In")
            appDelegate.setHomeViewController()

            if (url == G_LOGIN) {
                self.dismiss(animated: true, completion: nil)
            }
            self.stopActivityIndicator()
        }) { (errorMessage) in
            MessageManager.showAlert(nil, "\(errorMessage)")
            self.stopActivityIndicator()
        }
    }
}
