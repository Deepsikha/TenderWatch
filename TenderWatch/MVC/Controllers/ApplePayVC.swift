//
//  ApplePayVC.swift
//  TenderWatch
//
//  Created by devloper65 on 9/5/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit
import Stripe
import PassKit

class ApplePayVC: UIViewController, PKPaymentAuthorizationViewControllerDelegate {
    
    var shippingManager: ShippingManagers?
    var payButton: UIButton?
    var applePaySucceeded: Bool?
    var applePayError: NSError?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        title = "Apple Pay"
        
        shippingManager = ShippingManagers()
        let button = UIButton(type: UIButtonType.system)
        button.setTitle("Pay with Apple Pay", for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(self.pay), for: .touchUpInside)
        button.isEnabled = applePayEnabled()
        payButton = button
        view.addSubview(button)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let bounds: CGRect = view.bounds
        payButton?.center = CGPoint(x: bounds.midX, y: 100)
    }

    func applePayEnabled() -> Bool {
        let paymentRequest: PKPaymentRequest? = buildPaymentRequest()
        if paymentRequest != nil {
            return Stripe.canSubmitPaymentRequest(paymentRequest!)
        }
        return false
    }
    
    func buildPaymentRequest() -> PKPaymentRequest {
            let paymentRequest: PKPaymentRequest? = Stripe.paymentRequest(withMerchantIdentifier: "merchant.com.tenderWatch.imtiaz", country: "US", currency: "USD")
            paymentRequest?.requiredShippingAddressFields = .postalAddress
            paymentRequest?.requiredBillingAddressFields = .postalAddress
            paymentRequest?.shippingMethods = shippingManager?.defaultShippingMethods() as? [PKShippingMethod]
            paymentRequest?.paymentSummaryItems = summaryItems(for:(paymentRequest?.shippingMethods?.first)!) as! [PKPaymentSummaryItem]
            return paymentRequest!
    }

    func pay() {
        applePaySucceeded = false
        applePayError = nil
        let paymentRequest: PKPaymentRequest? = buildPaymentRequest()
        if Stripe.canSubmitPaymentRequest(paymentRequest!) {

            let auth = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest!)
            auth.delegate = self
                present(auth, animated: true) { _ in }
        }
    }
    
    func summaryItems(for shippingMethod: PKShippingMethod) -> [Any] {
        let shirtItem = PKPaymentSummaryItem(label: "Cool Shirt", amount: NSDecimalNumber(string: "10.00"))
        let total: NSDecimalNumber? = shirtItem.amount.adding(shippingMethod.amount)
        let totalItem = PKPaymentSummaryItem(label: "Stripe Shirt Shop", amount: total!)
        return [shirtItem, shippingMethod, totalItem]
    }
    
    //MARK:- PKPaymentAuthorizationViewControllerDelegate
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didSelectShippingContact contact: PKContact, completion: @escaping (PKPaymentAuthorizationStatus, [PKShippingMethod], [PKPaymentSummaryItem]) -> Void) {
        shippingManager?.fetchShippingCosts(forAddress: contact.postalAddress!, completion: {(_ shippingMethods: [Any], _ error: Error?) -> Void in
            if error != nil {
                completion(.failure, [], [])
                return
            }
            completion(.success, shippingMethods as! [PKShippingMethod], self.summaryItems(for: shippingMethods.first as! PKShippingMethod) as! [PKPaymentSummaryItem])
        })
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didSelect shippingMethod: PKShippingMethod, completion: @escaping (PKPaymentAuthorizationStatus, [PKPaymentSummaryItem]) -> Void) {
        completion(.success, summaryItems(for: shippingMethod) as! [PKPaymentSummaryItem])
    }

    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        if isNetworkReachable() {
            STPAPIClient.shared().createToken(with: payment) { (token, error) in
                if error != nil {
                    
                } else {
                    APIManager.shared.createCharge((token?.tokenId)!, amount: 500, completion: { (json, error) in
                        if error != nil {
                            print("Failed")
                            completion(.failure)
                        } else {
                            print("Success")
                            self.applePaySucceeded = true
                            completion(.success)
                        }
                    })
                }
            }
        } else {
            MessageManager.showAlert(nil, "No Internet!!!")
        }
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        DispatchQueue.main.async(execute: {() -> Void in
            self.dismiss(animated: true, completion: {() -> Void in
                if self.applePaySucceeded! {
                    MessageManager.showAlert(nil, "Payment successfully created")
                }
                else if (self.applePayError != nil) {
                    MessageManager.showAlert(nil, "Payment Faield")
                }
                self.applePaySucceeded = false
                self.applePayError = nil
            })
        })
    }
}

class ShippingManagers: NSObject {
    
    func defaultShippingMethods() -> [Any] {
        return californiaShippingMethods()
    }
    
    func fetchShippingCosts(forAddress address: CNPostalAddress, completion: @escaping (_ shippingMethods: [Any], _ error: Error?) -> Void) {
        let state = address.state
        if (state == "CA") {
            completion(californiaShippingMethods(), nil)
        }
        else {
            completion(internationalShippingMethods(), nil)
        }
    }
    
    func californiaShippingMethods() -> [Any] {
        let upsGround = PKShippingMethod()
        upsGround.amount = NSDecimalNumber(string: "0.00")
        upsGround.label = "UPS Ground"
        upsGround.detail = "Arrives in 3-5 days"
        upsGround.identifier = "ups_ground"
        let fedex = PKShippingMethod()
        fedex.amount = NSDecimalNumber(string: "5.99")
        fedex.label = "FedEx"
        fedex.detail = "Arrives tomorrow"
        fedex.identifier = "fedex"
        return [upsGround, fedex]
    }
    
    func internationalShippingMethods() -> [Any] {
        let upsWorldwide = PKShippingMethod()
        upsWorldwide.amount = NSDecimalNumber(string: "10.99")
        upsWorldwide.label = "UPS Worldwide Express"
        upsWorldwide.detail = "Arrives in 1-3 days"
        upsWorldwide.identifier = "ups_worldwide"
        return californiaShippingMethods() + [upsWorldwide]
    }
    
    
    
}
