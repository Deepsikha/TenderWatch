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
    
    var paymentTextField: STPPaymentCardTextField?
    var scrollView: UIScrollView?
    
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
        let paymentTextField = STPPaymentCardTextField()
        paymentTextField.delegate = self
        paymentTextField.cursorColor = UIColor.purple
        paymentTextField.postalCodeEntryEnabled = true
        self.paymentTextField = paymentTextField
        view.addSubview(self.paymentTextField!)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        let padding: CGFloat = 15
        let width: CGFloat = view.frame.width - (padding * 2)
        self.paymentTextField?.frame = CGRect(x: padding, y: padding, width: width, height: 44)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.paymentTextField?.becomeFirstResponder()
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
        if (!(self.paymentTextField?.isValid)!) {
            return
        }
        if !(Stripe.defaultPublishableKey() != nil) {
            MessageManager.showAlert(nil, "No publish key")
            return
        }
        self.startActivityIndicator()
        if isNetworkReachable() {
            STPAPIClient.shared().createToken(withCard: (paymentTextField?.cardParams)!) { (token, error) in
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
}
