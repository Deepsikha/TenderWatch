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
    
    //MARK: TextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: IBActions
    @IBAction func handleBtnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func handleBtnSubmit(_ sender: Any) {
        if !((self.txfEmail.text?.isEmpty)!) {
            forgot()
        }
    }
    
    func forgot() {
        let parameters = ["email" : self.txfEmail.text!]
        if isNetworkReachable() {
            Alamofire.request("\(BASE_URL)auth/forgot", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { (resp) in
                if(resp.result.value != nil) {
                    print(resp.result.value!)
                    MessageManager.showAlert(nil, "Password sent your register email address")
                }
            }
        } else {
            MessageManager.showAlert(nil, "No Internet")
        }
    }


/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destinationViewController.
 // Pass the selected object to the new view controller.
 }
 */

}
