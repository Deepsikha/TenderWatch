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
        let parameters = ["email" : self.txfEmail.text!]
        if isNetworkReachable() {
            self.startActivityIndicator()
            Alamofire.request(FORGOT, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (resp) in
                if(resp.result.value != nil) {
                    print(resp.result.value!)
                    MessageManager.showAlert(nil, "Password sent your register email address")
                    self.stopActivityIndicator()
                }
            }
        } else {
            MessageManager.showAlert(nil, "No Internet")
            self.stopActivityIndicator()
        }
    }
}
