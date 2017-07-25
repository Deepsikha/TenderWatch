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
import FBSDKLoginKit

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
        // TODO: Track the user action that is important for you.
//        Answers.logContentView(withName: "Tweet", contentType: "Video", contentId: "1234", customAttributes: ["Favorites Count":20, "Screen Orientation":"Landscape"])

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
                                          "role" : appDelegate.isClient! ? "client" : "contractor",
                                          "deviceId": appDelegate.token!]
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
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        
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
        appDelegate.isGoogle = true
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func btnHandleFacebook(_ sender: UIButton) {
        appDelegate.isGoogle = false
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                if fbloginresult.grantedPermissions != nil {
                    
                    if(fbloginresult.grantedPermissions.contains("email"))
                    {
                        let param: Parameters = ["token": FBSDKAccessToken.current()!.tokenString,
                                                 "role": appDelegate.isClient! ? "client" : "contractor",
                                                 "deviceId": appDelegate.token!]
//                        self.getFBUserData()
//                        fbLoginManager.logOut()
                        self.Login(F_LOGIN, param)
                    }
                }
            }
        }
    }

    @IBAction func btnHandleNewAC(_ sender: UIButton) {
        self.navigationController?.pushViewController(SignUpVC(), animated: true)
    }
    
    @IBAction func btnHandleForgot(_ sender: UIButton) {
        self.navigationController?.pushViewController(ForgotPasswordVC(), animated: true)
    }
    
    @IBAction func btnHandleSignIn(_ sender: UIButton) {
//        signUpUser =  signUpUserData()
        let parameters: Parameters = ["email" : self.txfEmail.text!,
                                      "password" : self.txfPassword.text!,
                                      "role" : appDelegate.isClient! ? "client" : "contractor",
                                      "deviceId": appDelegate.token!]
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
    
    func getFBUserData(){
        var dictInfo : [String : AnyObject]!
        var email: String?
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    dictInfo = result as! [String: AnyObject]
                    let isEmail = dictInfo.contains(where: { (key,value) -> Bool in
                        if (key == "email") {
                            email = value as? String
                            return true
                        } else {
                            return false
                        }
                    })
                    if (isEmail) {
                        let param: Parameters = ["token": email!,
                                                 "role": appDelegate.isClient! ? "client" : "contractor"]
                        self.Login(F_LOGIN, param)
                    } else {
                        MessageManager.showAlert(nil, "We can't access your information from Facebook because of your account privacy.")
                    }
                }
            })
        }
    }
}
