//
//  DirectPaymentVC.swift
//  TenderWatch
//
//  Created by devloper65 on 9/5/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit
import Stripe

class DirectPaymentVC: UIViewController, STPPaymentCardTextFieldDelegate, UIScrollViewDelegate {
    
    var imgCard = UIImageView()
    var paymentTextField = STPPaymentCardTextField()
    var scrollView = UIScrollView()
    var btnPayment = UIButton()
    
    override func loadView() {
        let scrollView = UIScrollView(frame: CGRect.zero)
        scrollView.delegate = self
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = UIColor.white
        view = scrollView
        self.scrollView = scrollView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Card"
        
        let buyButton = UIBarButtonItem(title: "Pay", style: .done, target: self, action: #selector(self.pay))
        buyButton.isEnabled = false
        self.navigationItem.rightBarButtonItem = buyButton
        
        self.imgCard.layer.backgroundColor = UIColor.lightGray.cgColor

        self.paymentTextField.delegate = self
        self.paymentTextField.cursorColor = UIColor.purple
        
        let btn = UIButton(frame: CGRect(x: 289, y: 31, width: 15, height: 15))
        btn.setImage(UIImage(named: "cancel"), for: .normal)
        btn.addTarget(self, action: #selector(btnCancel(_:)), for: .touchDown)
        
        btnPayment.setTitle("Payment", for: .normal)
        btnPayment.setTitleColor(UIColor.white, for: .normal)
        btnPayment.layer.backgroundColor = UIColor.appBlueColor.cgColor
        btnPayment.addTarget(self, action: #selector(self.pay), for: UIControlEvents.touchDown)
        view.addSubview(self.paymentTextField)
        view.addSubview(btnPayment)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        let padding: CGFloat = 15
        self.imgCard.frame = CGRect(x: 0, y: 64, width: self.view.frame.width, height: 240)
        self.paymentTextField.frame = CGRect(x: 15, y: self.imgCard.frame.origin.y + self.imgCard.frame.height + padding, width: self.view.frame.width - 30, height: 30)
        self.btnPayment.frame = CGRect(x: self.view.center.x - 100, y: (self.paymentTextField.frame.origin.y) + (self.paymentTextField.frame.height), width: 200, height: 35)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.paymentTextField.becomeFirstResponder()
    }
    
    func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
        self.navigationItem.rightBarButtonItem?.isEnabled = textField.isValid;
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pay() {
        if (!(self.paymentTextField.isValid)) {
            return
        }
        if !(Stripe.defaultPublishableKey() != nil) {
            MessageManager.showAlert(nil, "No publish key")
            return
        }
        self.startActivityIndicator()
        if isNetworkReachable() {
            STPAPIClient.shared().createToken(withCard: (paymentTextField.cardParams)) { (token, error) in
                if error != nil {
                    MessageManager.showAlert(nil, "Please Check your Card Info")
                    self.stopActivityIndicator()
                } else {
                    APIManager.shared.createCharge((token?.tokenId)!, amount: 500, completion: { (json, error) in
                        if (error == nil) {
                            print(json!)
                            MessageManager.showAlert(nil, "Thank You For Subscribe in Application.")
                            self.stopActivityIndicator()
                        } else {
                            print(error!)
                            MessageManager.showAlert(nil, "Please Try Again!!!")
                            self.stopActivityIndicator()
                        }
                    })
                }
            }
        } else {
            MessageManager.showAlert(nil, "No Internet!!!")
        }
    }
    @IBAction func btnCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
