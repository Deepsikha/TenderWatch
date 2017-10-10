//
//  SignUpVC.swift
//  TenderWatch
//
//  Created by lanetteam on 19/06/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit
import Google
import Alamofire
import SDWebImage
import FBSDKLoginKit

class SignUpVC: UIViewController, UITextFieldDelegate, GIDSignInUIDelegate, GIDSignInDelegate {
    
    @IBOutlet weak var vwEmail: UIView!
    @IBOutlet weak var vwPassword: UIView!
    @IBOutlet weak var vwConfirmPassword: UIView!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet var btnSignUpFacebook: UIButton!
    @IBOutlet weak var btnSignUpGmail: GIDSignInButton!
    @IBOutlet var btnBack: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        
        self.txtEmail.delegate = self
        self.txtConfirmPassword.delegate = self
        self.txtPassword.delegate = self
        
        self.txtEmail.autocorrectionType = .no
        self.txtConfirmPassword.autocorrectionType = .no
        self.txtPassword.autocorrectionType = .no
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
    
    //MARK:- Google SignIn Delegate
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            self.txtEmail.text = user.profile.email
            if user.profile.hasImage {
                SDWebImageManager.shared().imageDownloader?.downloadImage(with: user?.profile.imageURL(withDimension: 500), options: SDWebImageDownloaderOptions.progressiveDownload, progress: nil, completed: { (image, data, error, true) in
                    signUpUser.photo = data!
                })
            }
            self.stopActivityIndicator()
//            self.Login(G_LOGIN, parameters)
            self.dismiss(animated: true, completion: nil)
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
        self.startActivityIndicator()
    }
    //MARK:- IBActions
    @IBAction func handleBtnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSignUpClick(_ sender: Any) {
        if (self.txtEmail.text?.isEmpty)! && (self.txtPassword.text?.isEmpty)! {
            MessageManager.showAlert(nil, "Email & Password required!")
        } else {
            if isValidEmail(strEmail: self.txtEmail.text!) {
                if isValidPassword(strPassword: self.txtPassword.text!) && (self.txtPassword.text! == self.txtConfirmPassword.text) {
                    self.startActivityIndicator()
                    Alamofire.request(CHECKEMAIL, method: .post, parameters: ["email": self.txtEmail.text!, "role": appDelegate.isClient! ? "client" : "contractor"], encoding: JSONEncoding.default, headers: nil).responseJSON(completionHandler: { (resp) in
                        if resp.response?.statusCode == 404 {
                            signUpUser.email = self.txtEmail.text!
                            signUpUser.password = self.txtPassword.text!
                            self.navigationController?.pushViewController(SignUpVC2(), animated: true)
                            self.stopActivityIndicator()
                        } else {
                            MessageManager.showAlert(nil, "This Email is already used.\n\nPlease use another email to signup in TenderWatch")
                            self.stopActivityIndicator()
                        }
                    })
                } else {
                    if (!(self.txtPassword.text! == self.txtConfirmPassword.text)) {
                        MessageManager.showAlert(nil, "Password can't Match!!!")
                    } else if (self.txtConfirmPassword.text?.isEmpty)! {
                        MessageManager.showAlert(nil, "Enter confirm Password")
                    } else {
                        MessageManager.showAlert(nil, "Enter password with 8 characters which contain at least one alphabet, one number and special character")
                    }
                }
            } else {
                MessageManager.showAlert(nil, "Invalid Email")
            }
        }
    }
    
    @IBAction func handleBtnSignUpFacebook(_ sender: Any) {
        appDelegate.isGoogle = false
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["email", "user_about_me"], from: self) { (result, error) in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                if fbloginresult.grantedPermissions != nil {
                    
                    if(fbloginresult.grantedPermissions.contains("email")) {
                        self.startActivityIndicator()
                        Alamofire.request("https://graph.facebook.com/v2.10/ME?fields=email,picture.width(100).height(100)&access_token=\(FBSDKAccessToken.current()!.tokenString!)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON(completionHandler: { (resp) in
                            if resp.result.value != nil {
                                let data = resp.result.value as! NSObject
                                let key = (resp.result.value as! NSDictionary).allKeys.contains(where: { (a) -> Bool in
                                    if a as! String == "email" {
                                        return true
                                    } else {
                                        return false
                                    }
                                })
                                if key {
                                    self.txtEmail.text = data.value(forKey: "email") as? String
                                    let url = URL(string: ((data.value(forKey: "picture") as! NSObject).value(forKey: "data") as! NSObject).value(forKey: "url")! as! String)!
                                    SDWebImageManager.shared().imageDownloader?.downloadImage(with: url, options: .progressiveDownload, progress: nil, completed: { (image, data, error, true) in
                                        signUpUser.photo = data!
                                    })
                                    self.stopActivityIndicator()
                                } else {
                                    self.stopActivityIndicator()
                                    MessageManager.showAlert(nil, "You can't able to sign up using facebook.\nplease check your privacy or email verification in your facebook profile")
                                }
                            } else {
                                self.stopActivityIndicator()
                                MessageManager.showAlert(nil, "Please check your connection")
                            }
                        })
                    }
                }
            }
        }
    }
    
    @IBAction func handleBtnSignUpGmail(_ sender: Any) {
        appDelegate.isGoogle = true
        GIDSignIn.sharedInstance().signIn()
    }
}
