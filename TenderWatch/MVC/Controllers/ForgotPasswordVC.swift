//
//  ForgotPasswordVC.swift
//  TenderWatch
//
//  Created by devloper65 on 6/24/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit
import Alamofire

class ForgotPasswordVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var txfEmail: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txfEmail.becomeFirstResponder()
        txfEmail.delegate = self
        self.txfEmail.autocorrectionType = .no
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- TextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK:- IBActions
    @IBAction func handleBtnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func handleBtnSubmit(_ sender: Any) {
        if !((self.txfEmail.text?.isEmpty)!) {
            forgot()
        }
    }
    
    //MARK:- Custom Method
    func forgot() {
        let parameters = ["email" : self.txfEmail.text!,
                          "role" : appDelegate.isClient! ? "client": "contractor"] as [String : Any]
        if isNetworkReachable() {
            self.startActivityIndicator()
            Alamofire.request(FORGOT, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (resp) in
                if(resp.response?.statusCode == 200) {
                    print(resp.result.value!)
                    MessageManager.showAlert(nil, "Password has been sent to your registered email address")
                    self.stopActivityIndicator()
                    self.navigationController?.popViewController(animated: true)
                } else {
//                    let  msg = resp.result.value as 
                    self.stopActivityIndicator()
                    MessageManager.showAlert(nil, (resp.result.value as! NSObject).value(forKey: "message")! as! String)
                }
            }
        } else {
            MessageManager.showAlert(nil, "No Internet")
            self.stopActivityIndicator()
        }
    }
}
