//
//  PaymentVC.swift
//  Chat_App
//
//  Created by Devloper30 on 19/06/17.
//  Copyright © 2017 LaNet. All rights reserved.
//

import UIKit
import Alamofire
import Stripe
import PassKit
import ObjectMapper

class PaymentVC: UIViewController, PayPalPaymentDelegate, PayPalProfileSharingDelegate, STPAddCardViewControllerDelegate, PKPaymentAuthorizationViewControllerDelegate {
    
    @IBOutlet weak var btnBack: UIButton!
    //PaymentVC var
//    static var services = [Services]()
    static var service = [String: [String]]()
    
    //paypal 
    var item: [PayPalItem] = []
    var environment:String = PayPalEnvironmentSandbox {
        willSet(newEnvironment) {
            if (newEnvironment != environment) {
                PayPalMobile.preconnect(withEnvironment: newEnvironment)
            }
        }
    }
    
    //applepay
    var shippingManager = ShippingManager()
    var payButton: UIButton?
    var applePaySucceeded: Bool?
    var applePayError: NSError?
    
    var resultText = "" // empty
    var payPalConfig = PayPalConfiguration()

    var totalamount: NSDecimalNumber = 0.0
    override func viewDidLoad() {
        super.viewDidLoad()
        // payment screen
        let statusBarBackground = UIView(frame: UIApplication.shared.statusBarFrame)
        let statusBarColor = UIColor(red: 25/255, green: 103/255, blue: 201/255, alpha: 0.7)
        statusBarBackground.backgroundColor = statusBarColor
        view.addSubview(statusBarBackground)
        
        // Set up payPalConfig
        payPalConfig.acceptCreditCards = false
        payPalConfig.merchantName = "Awesome Shirts, Inc."
        payPalConfig.merchantPrivacyPolicyURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full")
        payPalConfig.merchantUserAgreementURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/useragreement-full")
        
        payPalConfig.languageOrLocale = Locale.preferredLanguages[0]
        payPalConfig.payPalShippingAddressOption = .payPal;
        
        if PaymentVC.service.isEmpty {
            self.getServices()
        } else {
            self.paybleAmount()
        }
        if (USER?.isPayment)! {
            self.btnBack.isHidden = false
        } else {
            self.btnBack.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        PayPalMobile.preconnect(withEnvironment: environment)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- PayPalPaymentDelegate
    
    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
        print("PayPal Payment Cancelled")
        resultText = ""
        paymentViewController.dismiss(animated: true, completion: nil)
    }
    
    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
        print("PayPal Payment Success !")
        paymentViewController.dismiss(animated: true, completion: { () -> Void in
            // send completed confirmaion to your server
            self.sendToServer(completedPayment.confirmation)
            self.resultText = completedPayment.description
            self.updateServicesAfterPayment()
        })
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

    
    //MARK:- Card Delegate
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        // Dismiss add card view controller
        dismiss(animated: true)
    }
    
    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreateToken token: STPToken, completion: @escaping STPErrorBlock) {
        
        if !(Stripe.defaultPublishableKey() != nil) {
            MessageManager.showAlert(nil, "No publish key")
            return
        }
        if isNetworkReachable() {
            self.startActivityIndicator()
            APIManager.shared.createCharge(token.tokenId, amount: self.totalamount.multiplying(by: 100), completion: { (json, error) in
                
                self.dismiss(animated: true, completion: {
                    if (error == nil) {
                        print(json!)
                        self.stopActivityIndicator()
                        self.updateServicesAfterPayment()
                    } else {
                        print(error!)
                        MessageManager.showAlert(nil, "Please Try Again!!!")
                        self.stopActivityIndicator()
                    }
                })
            })
        } else {
            MessageManager.showAlert(nil, "No Internet!!!")
        }
    }
    
    
    //MARK:- PKPaymentAuthorizationViewControllerDelegate
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didSelectShippingContact contact: PKContact, completion: @escaping (PKPaymentAuthorizationStatus, [PKShippingMethod], [PKPaymentSummaryItem]) -> Void) {
        shippingManager.fetchShippingCosts(forAddress: contact.postalAddress!, completion: {(_ shippingMethods: [Any], _ error: Error?) -> Void in
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
                    APIManager.shared.createCharge((token?.tokenId)!, amount: self.totalamount.multiplying(by: 100), completion: { (json, error) in
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
                    self.updateServicesAfterPayment()
                }
                else if (self.applePayError != nil) {
                    MessageManager.showAlert(nil, "Payment Faield")
                }
                self.applePaySucceeded = false
                self.applePayError = nil
            })
        })
    }
    
    //MARK:- IBActions
    @IBAction func btnHandleBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnHandlePayPal(_ sender: UIButton) {
        self.paymentMethod()
    }
    
    @IBAction func btnHandleCreditCard(_ sender: UIButton) {
        self.presentCardController()
    }
    
    @IBAction func btnHandleApplePay(_ sender: UIButton) {
        self.applePayConfig()
    }
    
    @IBAction func btnHandleBankPayment(_ sender: Any) {
        let nv = UINavigationController(rootViewController: BankPaymentVC())
        BankPaymentVC.price = self.totalamount
        self.present(nv, animated: true, completion: nil)
    }
    
    //MARK:- Custom Methods
    
    func paymentMethod() {

        self.item = []
        for i in PaymentVC.service {
            for j in i.value {
                let item = PayPalItem(name: "\(String(describing: i.key)) -> \(j)", withQuantity: 1, withPrice: NSDecimalNumber(string: USER?.subscribe == subscriptionType.monthly ? "15" : "120"), withCurrency: "USD", withSku: "")
                self.item.append(item)
            }
        }
        
        let subtotal = PayPalItem.totalPrice(forItems: self.item)

        // Optional: include payment details
        let shipping = NSDecimalNumber(string: "0.00")
        let tax = NSDecimalNumber(string: "0.00")
        let paymentDetails = PayPalPaymentDetails(subtotal: subtotal, withShipping: shipping, withTax: tax)
        
        let total = PayPalItem.totalPrice(forItems: self.item).adding(shipping).adding(tax)
        
        let payment = PayPalPayment(amount: total, currencyCode: "USD", shortDescription: "Charge", intent: .sale)
        
        payment.items = self.item
        payment.paymentDetails = paymentDetails
        
        if (payment.processable) {
            let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: payPalConfig, delegate: self)
            present(paymentViewController!, animated: true, completion: nil)
            self.stopActivityIndicator()
            
        }
        else {
            print("Payment not processalbe: \(payment)")
            self.stopActivityIndicator()
        }
    }
    
    //payment amount
    func paybleAmount() {
        
        self.item = []
        for i in PaymentVC.service {
            for j in i.value {
                let item = PayPalItem(name: "\(String(describing: i.key)) -> \(j)", withQuantity: 1, withPrice: NSDecimalNumber(string: USER?.subscribe == subscriptionType.monthly ? "15" : "120"), withCurrency: "USD", withSku: "")
                self.item.append(item)
            }
        }
        resultText = ""
        // Optional: include multiple items
        self.totalamount = PayPalItem.totalPrice(forItems: self.item)
    }
    
    //Debit card Method
    func presentCardController() {
        let addCardViewController = STPAddCardViewController()
        addCardViewController.delegate = self
        addCardViewController.title = "CreDit Card"
        // Present add card view controller
        let navigationController = UINavigationController(rootViewController: addCardViewController)
        self.present(navigationController, animated: true)
    }
    
    //applePay 
    func applePayConfig() {
        applePaySucceeded = false
        applePayError = nil
        let paymentRequest: PKPaymentRequest? = buildPaymentRequest()
        if Stripe.canSubmitPaymentRequest(paymentRequest!) {
            
            let auth = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest!)
            auth.delegate = self
            present(auth, animated: true) { _ in }
        }
    }
    
    func buildPaymentRequest() -> PKPaymentRequest {
        let paymentRequest: PKPaymentRequest? = Stripe.paymentRequest(withMerchantIdentifier: "merchant.com.tenderWatch.imtiaz", country: "US", currency: "USD")
        paymentRequest?.requiredShippingAddressFields = .postalAddress
        paymentRequest?.requiredBillingAddressFields = .postalAddress
        paymentRequest?.shippingMethods = shippingManager.defaultShippingMethods() as? [PKShippingMethod]
        paymentRequest?.paymentSummaryItems = summaryItems(for:(paymentRequest?.shippingMethods?.first)!) as! [PKPaymentSummaryItem]
        return paymentRequest!
    }
    
    func summaryItems(for shippingMethod: PKShippingMethod) -> [Any] {
        let shirtItem = PKPaymentSummaryItem(label: "Stripe", amount: self.totalamount)
        let total: NSDecimalNumber? = shirtItem.amount.adding(shippingMethod.amount)
        let totalItem = PKPaymentSummaryItem(label: "Stripe Shirt Shop", amount: total!)
        return [shirtItem, shippingMethod, totalItem]
    }
    //notify the server
    func donePayment() {
        
    }
    
    func sendToServer(_ param: [AnyHashable: Any]) {
        Alamofire.request(PAYPAL, method: .post, parameters: param as? Parameters, encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(UserManager.shared.user!.authenticationToken!)"]).responseJSON { (resp) in
            print("Here is your proof of payment:\n\n\(param)\n\nSend this to your server for confirmation and fulfillment.")
        }
    }
    
    func updateServicesAfterPayment() {
        if isNetworkReachable() {
            Alamofire.request(GET_SERVICES, method: .put, parameters: ["selections" : PaymentVC.service, "payment": self.totalamount], encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(UserManager.shared.user!.authenticationToken!)"]).responseJSON(completionHandler: { (resp) in
                if (resp.response?.statusCode == 200) {
                    let tempUser = USER
                    tempUser?.isPayment = true
                    tempUser?.payment = (USER?.isPayment!)! ?  self.totalamount.adding(USER?.payment as! NSDecimalNumber) as Float : USER?.payment
                    UserManager.shared.user = tempUser
                    appDelegate.setHomeViewController()
                    MessageManager.showAlert(nil, "Thank You.\n\nEnjoy your services in particular country and category.")
                } else {
                    MessageManager.showAlert(nil, "Services can't Updated.")
                }
            })
        } else {
            MessageManager.showAlert(nil, "No Internet!!!")
        }
    }
    
    func getServices() {
        if isNetworkReachable() {
            self.startActivityIndicator()
            Alamofire.request(GET_SERVICES, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(UserManager.shared.user!.authenticationToken!)"]).responseJSON(completionHandler: { (resp) in
                if(resp.result.value != nil) {
                    let data = (resp.result.value as! NSObject)
                    var services = [Services]()
                    services = Mapper<Services>().mapArray(JSONObject: data)!
                    services = services.sorted(by: { (a, b) -> Bool in
                        a.countryId! > b.countryId!
                    })
                    
                    var cId = ""
                    var catId: [String] = []
                    for ser in services {
                        if cId == ser.countryId {
                            for i in ser.categoryId! {
                                catId.append(i)
                            }
                            PaymentVC.service[cId] = catId
                        } else {
                            PaymentVC.service[ser.countryId!] = ser.categoryId
                            catId = ser.categoryId!
                        }
                        cId = ser.countryId!
                    }
                    self.paybleAmount()
                }
                self.stopActivityIndicator()
            })
        } else {
            MessageManager.showAlert(nil, "No Internet")
        }
    }
}
