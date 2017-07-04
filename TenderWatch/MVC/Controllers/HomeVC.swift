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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
