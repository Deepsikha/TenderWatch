//
//  SubscriptionVC.swift
//  TenderWatch
//
//  Created by devloper65 on 6/26/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import PassKit
import Stripe

class SubscriptionVC: UIViewController, UITableViewDelegate, UITableViewDataSource, PKPaymentAuthorizationViewControllerDelegate, PayPalPaymentDelegate, PayPalProfileSharingDelegate, STPPaymentContextDelegate, STPAddCardViewControllerDelegate {
    
    @IBOutlet weak var btnPayment: UIButton!
    @IBOutlet weak var tblSubscription: UITableView!
    
    var select = [String : [String]]()
    var country = [Country]()
    var category = [Category]()
    var selection = [Selections]()
    var sectionTitleList = [String]()
    var services = [Services]()
    
    var shippingManager = ShippingManager()
    var payButton: UIButton?
    var applePaySucceeded: Bool?
    var applePayError: NSError?
    
    var item: [PayPalItem] = []
    var environment:String = PayPalEnvironmentSandbox {
        willSet(newEnvironment) {
            if (newEnvironment != environment) {
                PayPalMobile.preconnect(withEnvironment: newEnvironment)
            }
        }
    }
    
    var resultText = "" // empty
    var payPalConfig = PayPalConfiguration()
    
    private var customerContext : STPCustomerContext?
    private var paymentContext : STPPaymentContext?
    private var price: Int = 0 {
        didSet {
            // Forward value to payment context
            paymentContext?.paymentAmount = price
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tblSubscription.delegate = self
        self.tblSubscription.dataSource = self
        
        self.tblSubscription.register(UINib(nibName: "RegisterCountryCell", bundle: nil), forCellReuseIdentifier: "RegisterCountryCell")
        self.tblSubscription.tableFooterView = UIView()
        
        title = "PayPal SDK Demo"
        // Set up payPalConfig
        payPalConfig.acceptCreditCards = false
        payPalConfig.merchantName = "Awesome Shirts, Inc."
        payPalConfig.merchantPrivacyPolicyURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full")
        payPalConfig.merchantUserAgreementURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/useragreement-full")
        
        payPalConfig.languageOrLocale = Locale.preferredLanguages[0]
        payPalConfig.payPalShippingAddressOption = .payPal;
        
        self.fetchCoutry()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        PayPalMobile.preconnect(withEnvironment: environment)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- TableView Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.services.count //self.country.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.services[section].categoryId?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RegisterCountryCell", for: indexPath) as! RegisterCountryCell
        let ser = self.services[indexPath.section]
//        cell.countryName.text = self.selection[indexPath.section].categoryId[indexPath.row]
        cell.countryName.text = ser.categoryId?[indexPath.row]
        cell.imgTick.isHidden = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.services[section].countryId
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.sectionTitleList
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
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
            APIManager.shared.createCharge(token.tokenId, amount: self.price, completion: { (json, error) in
            
                self.dismiss(animated: true, completion: {
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
            })
        } else {
            MessageManager.showAlert(nil, "No Internet!!!")
        }
    }
    
    //MARK:- STPPaymentContext Delegate
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        // Use generic error message
        print("[ERROR]: Unrecognized error while loading payment context: \(error)");
        
        present(UIAlertController(message: "Could not retrieve payment information", retryHandler: { (action) in
            // Retry payment context loading
            paymentContext.retryLoading()
        }), animated: true)
    }
    
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        // Reload related components
//        reloadPaymentButtonContent()
        //        switch paymentContext.selectedPaymentMethod.label :
        //        case
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPErrorBlock) {
        // Create charge using payment result
        
        APIManager.shared.completeCharge(paymentResult, amount: self.price) { (resp, error) in
            guard error == nil else {
                // Error while requesting ride
                completion(error)
                return
            }
            
            // Save ride info to display after payment finished
            print("start payment")
            completion(nil)
        }
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        switch status {
        case .success:
            print("success!!!")
            break
        case .error:
            // Use generic error message
            print("[ERROR]: Unrecognized error while finishing payment: \(String(describing: error))");
            MessageManager.showAlert(nil, "Could not request ride")
            break
            
        case .userCancellation:
            break
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
                    APIManager.shared.createCharge((token?.tokenId)!, amount: self.price, completion: { (json, error) in
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
    
    //MARK:- IBActions
    @IBAction func handleBtnMenu(_ sender: Any) {
        appDelegate.drawerController.toggleDrawerSide(.left, animated: true, completion: nil)
    }
    
    @IBAction func handleBtnPayment(_ sender: Any) {
        let vc = UINavigationController(rootViewController: SelectCountryVC())
//        let vc = SelectCountryVC(nibName: "SelectCountryVC", bundle: nil)
        self.present(vc, animated: true, completion: nil)
        
//        let option = UIAlertController(title: nil, message: "Payment Options", preferredStyle: .actionSheet)
//        
//        let paypal = UIAlertAction(title: "PayPal", style: .default) { (action) in
//            self.paymentMethod()
//        }
//        
//        let cards = UIAlertAction(title: "Debit/Credit Card", style: .default) { (action) in
//            self.presentCardController()
//        }
//        
//        let applePay = UIAlertAction(title: "ApplePay", style: .default) { (action) in
//            self.applePayConfig()
//        }
//        
//        let bank = UIAlertAction(title: "Using Bank a/c", style: .default) { (action) in
//            let nv = UINavigationController(rootViewController: BankPaymentVC())
//            BankPaymentVC.price = self.price
//            self.present(nv, animated: true, completion: nil)
//        }
//        
//        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: {
//            (alert: UIAlertAction!) -> Void in
//        })
//        
//        option.addAction(paypal)
//        option.addAction(cards)
//        option.addAction(applePay)
//        option.addAction(bank)
//        option.addAction(cancel)
//        self.present(option, animated: true, completion: nil)
        
    }
    
    //MARK:- Custom Methods
    func fetchCoutry() {
        if isNetworkReachable() {
            self.startActivityIndicator()
            APIManager.shared.requestForGET(url: COUNTRY, isTokenEmbeded: false, successHandler: { (finish, res) in
                if res.result.value != nil
                {
                    let data = (res.result.value as! NSObject)
                    self.country = Mapper<Country>().mapArray(JSONObject: data)!
                    self.fetchCategory()
                }
            }) { (errorMessage) in
                print(errorMessage)
            }
        } else {
            MessageManager.showAlert(nil, "No Internet")
        }
    }
    
    func fetchCategory() {
        if isNetworkReachable() {
            APIManager.shared.requestForGET(url: CATEGORY, isTokenEmbeded: false, successHandler: { (finish, res) in
                if res.result.value != nil
                {
                    let data = (res.result.value as! NSObject)
                    self.category = Mapper<Category>().mapArray(JSONObject: data)!
                    self.getServices()
                }
            }) { (errorMessage) in
                print(errorMessage)
            }
        } else {
            MessageManager.showAlert(nil, "No Internet")
        }
    }
    
    func getServices() {
        if isNetworkReachable() {
            Alamofire.request(GET_SERVICES, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(UserManager.shared.user!.authenticationToken!)"]).responseJSON(completionHandler: { (resp) in
                if(resp.response?.statusCode == 200) {
                    let data = (resp.result.value as! NSObject)
                    self.services = Mapper<Services>().mapArray(JSONObject: data)!
                    for ser in self.services {
                        self.select[ser.countryId!] = ser.categoryId
                    }
                    self.parse()
                } else {
                    MessageManager.showAlert("nil", "Try Again!!!")
                    self.stopActivityIndicator()
                }

            })
        } else {
            MessageManager.showAlert(nil, "No Internet")
        }
    }
    
    func parse() {
        var arr: [String] = []
        var count: Int = 0
        for i in self.services {
            arr.removeAll()
            i.countryId = self.country.filter{$0.countryId == i.countryId}[0].countryName
            for j in i.categoryId! {
                let category = self.category.filter{$0.categoryId == j}[0].categoryName
                arr.append(category!)
                count = count + 1
            }
            i.categoryId = arr
        }
        
        self.price = count * 12000
        self.services = self.services.sorted(by: { (a, b) -> Bool in
            a.countryId! < b.countryId!
        })
        self.splitDataInToSection()
    }
    
    func splitDataInToSection() {
        var sectionTitle: String = ""
        for i in 0..<self.services.count {
            let currentRecord = self.services[i].countryId
            let firstChar = currentRecord?[(currentRecord?.startIndex)!]
            let firstCharString = "\(String(describing: firstChar!))"
            if firstCharString != sectionTitle {
                sectionTitle = firstCharString
                self.sectionTitleList.append(sectionTitle)
            }
        }
        self.stopActivityIndicator()
        self.tblSubscription.reloadData()
    }
//    
//    func parse() {
//        var arr: [String] = []
//        var count: Int = 0
//        for i in self.select {
//            arr.removeAll()
//            let country = self.country.filter{$0.countryId == i.key}[0].countryName
//            for j in i.value {
//                let category = self.category.filter{$0.categoryId == j}[0].categoryName
//                arr.append(category!)
//                count = count + 1
//            }
//            let param = ["countryId": country!, "categoryId": arr] as [String : Any]
//            let selection = Mapper<Selections>().map(JSON: param)
//            self.selection.append(selection!)
//        }
//        
//        self.price = count * 12000
//        self.selection = self.selection.sorted(by: { (a, b) -> Bool in
//            a.countryId! < b.countryId!
//        })
//        self.splitDataInToSection()
//    }
//    
//    func splitDataInToSection() {
//        var sectionTitle: String = ""
//        for i in 0..<self.selection.count {
//            let currentRecord = self.selection[i].countryId
//            let firstChar = currentRecord?[(currentRecord?.startIndex)!]
//            let firstCharString = "\(String(describing: firstChar!))"
//            if firstCharString != sectionTitle {
//                sectionTitle = firstCharString
//                self.sectionTitleList.append(sectionTitle)
//            }
//        }
//        self.stopActivityIndicator()
//        self.tblSubscription.reloadData()
//    }
//    
    func paymentMethod() {
        for i in self.services {
            for j in i.categoryId! {
                let item = PayPalItem(name: "\(String(describing: i.countryId)) -> \(j)", withQuantity: 1, withPrice: NSDecimalNumber(string: "120.00"), withCurrency: "USD", withSku: "")
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
            self.stopActivityIndicator()
            
        }
        else {
            print("Payment not processalbe: \(payment)")
            self.stopActivityIndicator()
        }
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
        paymentRequest?.shippingMethods = shippingManager.defaultShippingMethods() as? [PKShippingMethod]
        paymentRequest?.paymentSummaryItems = summaryItems(for:(paymentRequest?.shippingMethods?.first)!) as! [PKPaymentSummaryItem]
        return paymentRequest!
    }
    
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
    
    func summaryItems(for shippingMethod: PKShippingMethod) -> [Any] {
        let shirtItem = PKPaymentSummaryItem(label: "Shirt", amount: NSDecimalNumber(value: self.price / 100))
        let total: NSDecimalNumber? = shirtItem.amount.adding(shippingMethod.amount)
        let totalItem = PKPaymentSummaryItem(label: "Stripe Shirt Shop", amount: total!)
        return [shirtItem, shippingMethod, totalItem]
    }
    
    func sendToServer(_ param: [AnyHashable: Any]) {
        Alamofire.request(PAYPAL, method: .post, parameters: param as? Parameters, encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(UserManager.shared.user!.authenticationToken!)"]).responseJSON { (resp) in
            print("Here is your proof of payment:\n\n\(param)\n\nSend this to your server for confirmation and fulfillment.")
        }
    }
    
    func setEnvForStripe() {
        customerContext = STPCustomerContext(keyProvider: APIManager.shared)
        paymentContext = STPPaymentContext(customerContext: customerContext!)
        paymentContext?.delegate = self
        paymentContext?.hostViewController = self
        
        presentPaymentMethodsViewController()
    }
    
    func presentPaymentMethodsViewController() {
        guard !STPPaymentConfiguration.shared().publishableKey.isEmpty else {
            // Present error immediately because publishable key needs to be set
            MessageManager.showAlert(nil, "Please assign a value to `publishableKey` before continuing. See `AppDelegate.swift`.")
            return
        }
        
        guard !BASE_URL.isEmpty else {
            // Present error immediately because base url needs to be set
            MessageManager.showAlert(nil, "Please assign a value to `MainAPIClient.shared.baseURLString` before continuing. See `AppDelegate.swift`.")
            return
        }
        
        // Present the Stripe payment methods view controller to enter payment details
        paymentContext?.presentPaymentMethodsViewController()
    }
    
    func presentCardController() {
        
        let addCardViewController = STPAddCardViewController()
        addCardViewController.delegate = self
        addCardViewController.title = "CreDit Card"
        // Present add card view controller
        let navigationController = UINavigationController(rootViewController: addCardViewController)
        self.present(navigationController, animated: true)
    }
    
}

class ShippingManager: NSObject {
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
