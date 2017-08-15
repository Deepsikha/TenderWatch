//
//  SupportVC.swift
//  TenderWatch
//
//  Created by devloper65 on 8/1/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit
import Alamofire

class SupportVC: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var txfEmailReceiver: UITextField!
    @IBOutlet weak var txfSubject: UITextField!
    @IBOutlet weak var txtVwDesc: UITextView!
    @IBOutlet weak var btnSend: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.txfEmailReceiver.delegate = self
        self.txfSubject.delegate = self
        self.txtVwDesc.delegate = self
        
        
        self.btnSend.alpha = 0.5
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        self.txtVwDesc.layer.cornerRadius = 5
        self.txtVwDesc.layer.borderColor = UIColor.lightGray.cgColor
        self.txtVwDesc.layer.borderWidth = 1
        
        self.btnSend.layer.cornerRadius = self.btnSend.frame.height / 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.txfEmailReceiver.text = USER!.email!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- TextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == self.txfEmailReceiver) {
            textField.resignFirstResponder()
            self.txfSubject.becomeFirstResponder()
            return true
        } else {
            textField.resignFirstResponder()
            self.txtVwDesc.becomeFirstResponder()
            return false
        }
    }

    //MARK:- TextView Delegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == self.txtVwDesc {
            if !(textView.text.isEmpty) {
                if textView.text == "Enter your Questions or Complain" {
                    textView.text = ""
                    textView.textColor = UIColor.black
                }
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if (textView == self.txtVwDesc) {
            if textView.text.isEmpty {
                textView.text = "Enter your Questions or Complain"
                textView.textColor = UIColor.lightGray
            } else {
                
            }
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if (textView.text.isEmpty) || textView.text == "Enter your Questions or Complain"{
            self.btnSend.isEnabled = true
            self.btnSend.alpha = 0.5
        } else {
            self.btnSend.isEnabled = true
            self.btnSend.alpha = 1.0
        }
    }
    
    //MARK:- IBActions
    @IBAction func handleBtnMenu(_ sender: Any) {
        appDelegate.drawerController.toggleDrawerSide(.left, animated: true, completion: nil)
    }

    @IBAction func handleBtnSend(_ sender: Any) {
        let param: Parameters = ["subject": self.txfSubject.text!,
                                 "description":self.txtVwDesc.text!]
        
        if (self.txtVwDesc.text! != "Enter your Questions or Complain") {
            if isNetworkReachable() {
                Alamofire.request(SUPPORT, method: .post, parameters: param, encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(UserManager.shared.user!.authenticationToken!)"]).responseJSON(completionHandler: { (resp) in
                    if (resp.result.value != nil) {
                        
                    }
                })
            } else {
                MessageManager.showAlert(nil, "No Internet")
            }
        } else {
            MessageManager.showAlert(nil, "Enter your Questions or Complain")
        }
    }
}
