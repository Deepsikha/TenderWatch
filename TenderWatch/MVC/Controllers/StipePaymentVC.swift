//
//  StipePaymentVC.swift
//  TenderWatch
//
//  Created by devloper65 on 9/4/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit
import Stripe

class StipePaymentVC: UIViewController, STPPaymentContextDelegate  {

    private var customerContext : STPCustomerContext?
    private var paymentContext : STPPaymentContext?
    var cntrl: STPPaymentMethodsViewController?
    private var price = 100 {
        didSet {
            // Forward value to payment context
            paymentContext?.paymentAmount = price
        }
    }
    
    @IBOutlet var paymentButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        customerContext = STPCustomerContext(keyProvider: APIManager.shared)
        paymentContext = STPPaymentContext(customerContext: customerContext!)
        paymentContext?.delegate = self
        paymentContext?.hostViewController = self
        paymentButton.layer.cornerRadius = 5
        presentPaymentMethodsViewController()
        
        // Setup payment methods view controller

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //IBActions
    @IBAction private func handlePaymentButtonTapped() {
        paymentContext?.requestPayment()
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
        reloadPaymentButtonContent()
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
            self.dismiss(animated: true, completion: nil)

            MessageManager.showAlert(nil, "Try Again!!!")
            break
            
        case .userCancellation:
            break
        }
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didUpdateShippingAddress address: STPAddress, completion: @escaping STPShippingMethodsCompletionBlock) {
        
    }

    
    //MARK:- Custom Methods
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
    
    func reloadPaymentButtonContent() {
        guard let selectedPaymentMethod = paymentContext?.selectedPaymentMethod else {
            // Show default image, text, and color
            paymentButton.setImage(#imageLiteral(resourceName: "apple.png"), for: .normal)
            paymentButton.setTitle("Payment", for: .normal)
            paymentButton.setTitleColor(.appGrayColor, for: .normal)
            return
        }
        
        // Show selected payment method image, label, and darker color
        paymentButton.setImage(selectedPaymentMethod.image, for: .normal)
        paymentButton.setTitle(selectedPaymentMethod.label, for: .normal)
        paymentButton.setTitleColor(.appDarkBlueColor, for: .normal)
    }
}
