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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnContractor.cornerRedius()
        btnClient.cornerRedius()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        signUpUser =  signUpUserData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- IBActions
    @IBAction func btnContractorClick(_ sender: Any) {
        appDelegate.isClient = false
        signUpUser.role = "contractor"
        self.navigationController?.pushViewController(SignInVC(), animated: true)
        
    }
    
    @IBAction func btnClientClick(_ sender: Any) {
        appDelegate.isClient = true
        signUpUser.role = "client"
        self.navigationController?.pushViewController(SignInVC(), animated: true)
    }
}
