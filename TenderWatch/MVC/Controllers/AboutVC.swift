//
//  AboutVC.swift
//  TenderWatch
//
//  Created by devloper65 on 6/24/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit

class AboutVC: UIViewController, UITextViewDelegate {
    
    

    @IBOutlet weak var txtAbout: UITextView!
    
    @IBOutlet weak var lblCharLimit: UILabel!
    var limitLength = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtAbout.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        if(signUpUser.aboutMe.isEmpty) {
            txtAbout.text = "Enter some information about yourself"
            txtAbout.textColor = UIColor.lightGray
        } else {
        self.txtAbout.text = signUpUser.aboutMe
        }
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if (signUpUser.aboutMe.isEmpty) {
        if txtAbout.textColor == UIColor.lightGray {
            txtAbout.text = ""
            txtAbout.textColor = UIColor.black
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {

        if txtAbout.text.isEmpty {
            txtAbout.text = "Enter some information about yourself"
            txtAbout.textColor = UIColor.lightGray
            }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.txtAbout.resignFirstResponder()
    }
    
    @IBAction func handleBtnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func handleBtnSave(_ sender: Any) {
        signUpUser.aboutMe = self.txtAbout.text!
        self.navigationController?.popViewController(animated: false)
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let text = txtAbout.text else { return true }
        
        let newLength = text.characters.count + text.characters.count - range.length
        if(newLength <= limitLength){
            self.lblCharLimit.text = "\(1000 - newLength)"+"/1000"
            return true
        }else{
            return false
        }

    }
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        
//        guard let text = txtAbout.text else { return true }
//        
//        let newLength = text.characters.count + string.characters.count - range.length
//        if(newLength <= limitLength){
//            self.lblCharLimit.text = "\(1000 - newLength)"+"/1000"
//            return true
//        }else{
//            return false
//        }
//    }
}
