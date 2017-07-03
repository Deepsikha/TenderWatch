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

}
