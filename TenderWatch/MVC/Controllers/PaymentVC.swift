//
//  PaymentVC.swift
//  Chat_App
//
//  Created by Devloper30 on 19/06/17.
//  Copyright © 2017 LaNet. All rights reserved.
//

import UIKit

class PaymentVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let statusBarBackground = UIView(frame: UIApplication.shared.statusBarFrame)
        let statusBarColor = UIColor(red: 25/255, green: 103/255, blue: 201/255, alpha: 0.7)
        statusBarBackground.backgroundColor = statusBarColor
        view.addSubview(statusBarBackground)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- IBActions
    @IBAction func btnHandleBack(_ sender: UIButton) {
        appDelegate.setHomeViewController()
    }
    
    @IBAction func btnHandlePayPal(_ sender: UIButton) {
//        self.navigationController?.pushViewController(PayPalVC(nibName: "PayPalVC", bundle: nil), animated: true)
    }
    
    @IBAction func btnHandleCreditCard(_ sender: UIButton) {
        self.navigationController?.pushViewController(DirectPaymentVC(nibName: "DirectPaymentVC", bundle: nil), animated: true)
    }
    
    @IBAction func btnHandleApplePay(_ sender: UIButton) {
//        self.navigationController?.pushViewController(ApplePayVC(nibName: "ApplePayVC", bundle: nil), animated: true)
    }
}
