//
//  AboutVC.swift
//  TenderWatch
//
//  Created by devloper65 on 6/24/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit
import IQKeyboardManager

class AboutVC: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var txtAbout: UITextView!
    @IBOutlet weak var lblCharLimit: UILabel!
    
    var limitLength = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtAbout.delegate = self
        txtAbout.isScrollEnabled = false
        if (USER?.authenticationToken != nil) {
            lblCharLimit.text = "\(limitLength - (USER?.aboutMe?.characters.count)!) / 1000"
        } else {
            lblCharLimit.text = "\(limitLength - signUpUser.aboutMe.characters.count) / 1000"
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        IQKeyboardManager.shared().previousNextDisplayMode = .alwaysHide
        self.navigationController?.isNavigationBarHidden = true
        if (USER?.authenticationToken != nil) {
            if (USER?.aboutMe?.isEmpty)! {
                txtAbout.text = "Enter some information about yourself"
                txtAbout.textColor = UIColor.lightGray
            } else {
                txtAbout.text = USER?.aboutMe!
            }
        } else {
            if(signUpUser.aboutMe.isEmpty) {
                txtAbout.text = "Enter some information about yourself"
                txtAbout.textColor = UIColor.lightGray
            } else {
                self.txtAbout.text = signUpUser.aboutMe
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.txtAbout.resignFirstResponder()
    }
    
    //MARK:- textView Delegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        if (signUpUser.aboutMe.isEmpty) {
            if txtAbout.textColor == UIColor.lightGray {
                txtAbout.text = ""
                txtAbout.textColor = UIColor.black
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let aboutStr = txtAbout.text else { return true }
        let newLength = aboutStr.characters.count + text.characters.count - range.length
        
        if(newLength <= limitLength){
            self.lblCharLimit.text = "\(1000 - newLength)"+" / 1000"
            return true
        }else{
            return false
        }
    }
    
    //MARK:- IBActions
    @IBAction func handleBtnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func handleBtnSave(_ sender: Any) {
        if(self.txtAbout.text.characters.count > 0) {
            if (USER?.authenticationToken == nil) {
                signUpUser.aboutMe = self.txtAbout.text!
            } else {
                if !(USER!.aboutMe! == self.txtAbout.text!) {
                    SignUpVC2.isUpdated = true
                }
                USER?.aboutMe = self.txtAbout.text!
            }
            self.navigationController?.popViewController(animated: false)
        } else {
                MessageManager.showAlert(nil, "Enter some information about yourself")
                self.txtAbout.delegate = self
                self.txtAbout.reloadInputViews()
            }
        }
}
