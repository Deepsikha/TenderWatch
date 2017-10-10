//
//  HomeVC.swift
//  TenderWatch
//
//  Created by lanetteam on 19/06/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit

class HomeVC: UIViewController {
    
    @IBOutlet weak var btnContractor: UIButton!
    @IBOutlet weak var lblFirst: UILabel!
    @IBOutlet weak var lblSecond: UILabel!
    @IBOutlet weak var lblThird: UILabel!
    @IBOutlet weak var btnClient: UIButton!
    @IBOutlet weak var btnAboutApp: UIButton!
    @IBOutlet var vwTxtAbout: UIView!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var txtVwAbout: UITextView!
    @IBOutlet weak var vw: UIView!
    var transperentView = UIView()
    override func viewDidLoad() {
        super.viewDidLoad()
        btnContractor.cornerRedius()
        btnClient.cornerRedius()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        signUpUser =  signUpUserData()
        self.vw.layer.cornerRadius = 8
        self.btnClose.cornerRedius()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        self.vwTxtAbout.frame = self.view.frame
        
    }
    //MARK:- IBActions
    @IBAction func btnContractorClick(_ sender: Any) {
        appDelegate.isClient = false
        self.navigationController?.pushViewController(SignInVC(), animated: true)
        
    }
    
    @IBAction func btnClientClick(_ sender: Any) {
        appDelegate.isClient = true
        self.navigationController?.pushViewController(SignInVC(), animated: true)
    }
    
    @IBAction func handleBtnAboutApp(_ sender: Any) {
        if !self.view.subviews.contains(self.vwTxtAbout) {
            self.view.addSubview(self.vwTxtAbout)
        }
    }
    
    @IBAction func handleBtnClose(_ sender: Any) {
        if self.view.subviews.contains(self.vwTxtAbout) {
            self.vwTxtAbout.removeFromSuperview()
        }
    }
}
