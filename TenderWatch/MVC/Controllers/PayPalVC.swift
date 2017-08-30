//
//  PayPalVC.swift
//  TenderWatch
//
//  Created by devloper65 on 8/29/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit
import Alamofire

enum subscriptionType {
    case none
    case free
    case monthly
    case yearly
}

class PayPalVC: UIViewController, PayPalPaymentDelegate, PayPalProfileSharingDelegate {
    var select = [String : [String]]()
    var item: [PayPalItem] = []
    var rate: Double!
    
    var environment:String = PayPalEnvironmentSandbox {
        willSet(newEnvironment) {
            if (newEnvironment != environment) {
                PayPalMobile.preconnect(withEnvironment: newEnvironment)
            }
        }
    }
    
    var resultText = "" // empty
    var payPalConfig = PayPalConfiguration() // default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if (subscriptionType.monthly) {
        
//        }
        // Do any additional setup after loading the view.
        title = "PayPal SDK Demo"
        
        // Set up payPalConfig
        payPalConfig.acceptCreditCards = false
        payPalConfig.merchantName = "Awesome Shirts, Inc."
        payPalConfig.merchantPrivacyPolicyURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full")
        payPalConfig.merchantUserAgreementURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/useragreement-full")
        
        payPalConfig.languageOrLocale = Locale.preferredLanguages[0]
        payPalConfig.payPalShippingAddressOption = .payPal;
        
        print("PayPal iOS SDK Version: \(PayPalMobile.libraryVersion())")
        self.getServices()
//        pay()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        PayPalMobile.preconnect(withEnvironment: environment)
    }
    
    // PayPalPaymentDelegate
    
    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
        print("PayPal Payment Cancelled")
        resultText = ""
        paymentViewController.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
        print("PayPal Payment Success !")
        paymentViewController.dismiss(animated: true, completion: { () -> Void in
            // send completed confirmaion to your server
            self.sendToServer(completedPayment.confirmation)
            self.resultText = completedPayment.description
        })
        self.navigationController?.popViewController(animated: true)
    }
    
    func userDidCancel(_ profileSharingViewController: PayPalProfileSharingViewController) {
        print("PayPal Profile Sharing Authorization Canceled")
        profileSharingViewController.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    func payPalProfileSharingViewController(_ profileSharingViewController: PayPalProfileSharingViewController, userDidLogInWithAuthorization profileSharingAuthorization: [AnyHashable: Any]) {
        print("PayPal Profile Sharing Authorization Success!")
        
        // send authorization to your server
        
        profileSharingViewController.dismiss(animated: true, completion: { () -> Void in
            self.resultText = profileSharingAuthorization.description
        })
        self.navigationController?.popViewController(animated: true)
    }
    
    func pay() {
        for i in self.select {
            for j in i.value {
                let item = PayPalItem(name: "\(i.key) -> \(j)", withQuantity: 1, withPrice: NSDecimalNumber(string: "120.00"), withCurrency: "USD", withSku: "")
                self.item.append(item)
            }
        }
        
        resultText = ""
        // Optional: include multiple items
        
        let subtotal = PayPalItem.totalPrice(forItems: self.item)
        
        // Optional: include payment details
        let shipping = NSDecimalNumber(string: "10.00")
        let tax = NSDecimalNumber(string: "5.00")
        let paymentDetails = PayPalPaymentDetails(subtotal: subtotal, withShipping: shipping, withTax: tax)
        
        let total = subtotal.adding(shipping).adding(tax)
        
        let payment = PayPalPayment(amount: total, currencyCode: "USD", shortDescription: "Charge", intent: .sale)
        
        payment.items = self.item
        payment.paymentDetails = paymentDetails
        
        if (payment.processable) {
            let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: payPalConfig, delegate: self)
            present(paymentViewController!, animated: true, completion: nil)
        }
        else {
            print("Payment not processalbe: \(payment)")
        }
    }
    
    func sendToServer(_ param: [AnyHashable: Any]) {
        Alamofire.request(PAYPAL, method: .post, parameters: param as? Parameters, encoding: JSONEncoding.default, headers: ["Authorozation": "Bearer \(UserManager.shared.user!.authenticationToken!)"]).responseJSON { (resp) in
            print("Here is your proof of payment:\n\n\(param)\n\nSend this to your server for confirmation and fulfillment.")
        }
    }
    
    func getServices() {
        if isNetworkReachable() {
            self.startActivityIndicator()
            Alamofire.request(GET_SERVICES, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(UserManager.shared.user!.authenticationToken!)"]).responseJSON(completionHandler: { (resp) in
                if(resp.result.value != nil) {
                    self.select = resp.result.value as! [String : [String]]
                    print(self.select)
                    self.pay()
                }
                print(resp.result)
                self.stopActivityIndicator()
            })
        } else {
            MessageManager.showAlert(nil, "No Internet")
        }
    }
}
