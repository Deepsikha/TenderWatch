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

class SignInVC: UIViewController, UITextFieldDelegate, GIDSignInUIDelegate {
    
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
    
    //Google signIn Delegate
//    func signInWillDispatch(signIn: GIDSignIn!, error: NSError!) {
//        myActivityIndicator.stopAnimating()
//    }
    
    // Present a view that prompts the user to sign in with Google
    func sign(_ signIn: GIDSignIn!,
              present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    // Dismiss the "Sign in with Google" view
    func sign(_ signIn: GIDSignIn!,
              dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
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
        let parameters = ["email" : self.txfEmail.text!,
                          "password" : self.txfPassword.text!,
                          "role" : signUpUser.role]
        print(parameters)
        startActivityIndicator()
        UserManager.shared.signInUser(with: parameters, successHandler: { (user) in
            print("Logged In")
            appDelegate.setHomeViewController()
            self.stopActivityIndicator()
        }) { (errorMessage) in
            MessageManager.showAlert(nil, errorMessage)
            self.stopActivityIndicator()
        }
    }
}
