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
    
    //MARK:- SignIn Delegate
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            //send token or signupUserdata to server
            // Perform any operations on signed in user here.
            let userId = user.userID
            print()// For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name
            let givenName = user.profile.givenName
            let familyName = user.profile.familyName
            let email = user.profile.email
            // ...
            self.dismiss(animated: true, completion: nil)
            let parameters: Parameters = ["token" : user.authentication.idToken,
                                          "role" : signUpUser.role]
            self.Login(parameters)
        } else {
            print("\(error.localizedDescription)")
        }
    }
    
    //Google signIn Delegate
    
    func sign(_ signIn: GIDSignIn!,
              present viewController: UIViewController!) {
        // Present a view that prompts the user to sign in with Google
        self.present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!,
              dismiss viewController: UIViewController!) {
        // Dismiss the "Sign in with Google" view
//        self.dismiss(animated: false, completion: nil)
        
        
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
        self.Login(parameters)
    }
    
    func Login(_ param: Parameters) {
        
        startActivityIndicator()
        UserManager.shared.signInUser(with: param, successHandler: { (user) in
            print("Logged In")
            self.dismiss(animated: true, completion: nil)
            appDelegate.setHomeViewController()
            self.stopActivityIndicator()
        }) { (errorMessage) in
            self.dismiss(animated: true, completion: nil)
            MessageManager.showAlert(nil, "This Gmail Account doesn't exist in our Application.")
            self.stopActivityIndicator()
        }
    }
    
}
