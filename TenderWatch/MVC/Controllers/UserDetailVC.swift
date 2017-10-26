//
//  UserDetailVC.swift
//  TenderWatch
//
//  Created by devloper65 on 8/10/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit
import SDWebImage
import Alamofire
import ObjectMapper
import MessageUI

class UserDetailVC: UIViewController, UIScrollViewDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var btnEmail: UIButton!
    @IBOutlet weak var btnPhoneNumber: UIButton!
    @IBOutlet weak var txfOccupation: UITextField!
    @IBOutlet weak var txfCountry: UITextField!
    @IBOutlet weak var btnAboutMe: UIButton!
    
    @IBOutlet weak var vwStack: RatingControl!
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var lblAvg: UILabel!
    @IBOutlet weak var lblRatings: UILabel!
    @IBOutlet weak var btnSubmit: UIButton!
    
    @IBOutlet var vwImage: UIView!
    @IBOutlet weak var imgScrollView: ImageScrollView!
    
    var id: String!
    static var rate: Int = 0
    var transperentView = UIView()
    var txtVw = UITextView()
    
    var user: User!
    override func viewDidLoad() {
        super.viewDidLoad()
        if !(appDelegate.isClient!) {
            self.lblTitle.text = "Client Detail"
        } else {
            self.lblTitle.text = "Contractor Detail"
        }
        self.txtVw.layer.cornerRadius = 5
        self.txtVw.font = UIFont.systemFont(ofSize: 18)
        self.txtVw.isUserInteractionEnabled = false
        self.btnAboutMe.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        
        NotificationCenter.default.addObserver(self, selector: #selector(rate(notification:)), name: NSNotification.Name(rawValue : "rate"), object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapHandler(sender:)))
        tap.cancelsTouchesInView = false
        self.imgUser.addGestureRecognizer(tap)
        
        let btn = UIButton(frame: CGRect(x: 10, y: 30, width: 30, height: 30))
        btn.setImage(UIImage(named: "cancel-menu"), for: .normal)
        btn.layer.backgroundColor = UIColor.clear.cgColor
        btn.addTarget(self, action: #selector(self.tapHandler(sender:)), for: .touchDown)
        vwImage.addSubview(btn)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.imgUser.layer.cornerRadius = self.imgUser.frame.height / 2
        self.navigationController?.isNavigationBarHidden = true
        
        Alamofire.request(USERS+"\(self.id!)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(UserManager.shared.user!.authenticationToken!)"]).responseJSON { (resp) in
            if resp.result.value == nil {
                
            } else {
                let data = resp.result.value as! NSObject
                self.user = Mapper<User>().map(JSONObject: data)
                self.imgUser.sd_setImage(with: URL(string: (self.user.profilePhoto)!), placeholderImage: UIImage(named: "avtar"), options: SDWebImageOptions.progressiveDownload) { (image, error, memory, url) in
                    if image != nil {
                        self.imgScrollView.display(image: image!)
                    } else {
                        self.imgScrollView.display(image:
                            UIImage(named: "avtar")!)
                    }
                }
                self.btnEmail.setTitle(self.user.email!, for: .normal)
                
                self.txfCountry.text = self.user.country!
                
                self.btnPhoneNumber.setTitle(self.user.contactNo!, for: .normal)
                
                self.txfOccupation.text = self.user.occupation!
                
                self.txtVw.text = self.user.aboutMe!
                self.lblAvg.text = String(describing: self.user.avg!) + " / 5.0"
                self.vwStack.rating = (self.user.review!.rating)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        self.transperentView.frame = self.view.frame
        self.txtVw.frame = CGRect(x: self.view.frame.width / 2 - 130, y: self.view.frame.height / 2 - 150, width: 260, height: 300)
        
        self.vwImage.frame = self.view.frame
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //store rating
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- MailViewControllerDelegate
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        switch result {
        case .cancelled:
            print("Mail cancelled")
        case .saved:
            print("Mail saved")
        case .sent:
            print("Mail sent")
        case .failed:
            print("Mail sent failure:"+(error?.localizedDescription)!)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK:- IBAction
    
    @IBAction func handleBtnEmail(_ sender: Any) {
        
        let emailTitle = "TenderWatch"
        let messageBody = "Enter Your Message Here"
        let toRecipents = [self.btnEmail.titleLabel!.text]
        if MFMailComposeViewController.canSendMail() {
            let mc: MFMailComposeViewController = MFMailComposeViewController()
            mc.mailComposeDelegate = self
            mc.setSubject(emailTitle)
            mc.setMessageBody(messageBody, isHTML: false)
            mc.setMessageBody(messageBody, isHTML: false)
            mc.setToRecipients(toRecipents as? [String])
            
            self.present(mc, animated: true, completion: nil)
        } else {
            print("Nthi chaltu")
        }
        
    }
    
    @IBAction func handleBtnPhoneNumber(_ sender: Any) {
        let number = (self.btnPhoneNumber.titleLabel?.text?.components(separatedBy: "-").first)! + (self.btnPhoneNumber.titleLabel?.text?.components(separatedBy: "-").last)!
        let phoneCallURL = URL(string: "telprompt://"+number) //telprompt
        if phoneCallURL != nil {
            
            if UIApplication.shared.canOpenURL(phoneCallURL!) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(phoneCallURL!, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(phoneCallURL!)
            }
            } else {
                print("Nthi chaltu")
            }
        }
    }
    
    @IBAction func handleBtnRating(_ sender: Any) {
        if isNetworkReachable() {
            self.stopActivityIndicator()
            let param: Parameters!
            let method: HTTPMethod!
            let url: String!
            
            if (self.user.review?.id == "no id") {
                method = .post
                param = ["user" : self.user._id!,
                         "rating": UserDetailVC.rate]
                url = RATING
            } else {
                method = .put
                param = ["rating": UserDetailVC.rate]
                url = RATING+"\(self.user.review!.id!)"
            }
            
            Alamofire.request(url, method: method, parameters: param, encoding: JSONEncoding.default, headers: ["Authorization":"Bearer \(UserManager.shared.user!.authenticationToken!)"]).responseJSON { (resp) in
                if(resp.response?.statusCode == 200) {
                    let data = (resp.result.value as! NSObject)
                    self.lblAvg.text = "\(String(describing: data.value(forKey: "avg")!)) / 5.0"
                    
                    self.vwStack.rating = data.value(forKey: "rating") as! Int
                    MessageManager.showAlert(nil, "Thank you for Giving rating")
                    self.stopActivityIndicator()
                }
            }
        } else {
            MessageManager.showAlert(nil, "No Internet")
        }
        print("submit")
    }
    
    @IBAction func handleBtnCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func handleBtnAboutMe(_ sender: Any) {
        self.transperentView = UIView(frame: self.view.frame)
        self.transperentView.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.25)
        self.transperentView.addSubview(self.txtVw)
        if !self.view.subviews.contains(self.transperentView) {
            self.view.addSubview(self.transperentView)
        }
        let tapBtn = UITapGestureRecognizer(target: self, action: #selector(self.tapHandler(sender:)))
        tapBtn.cancelsTouchesInView = false
        tapBtn.accessibilityHint = "AboutMe"
        self.transperentView.addGestureRecognizer(tapBtn)
    }
    
    
    
    //MARK:- Custom Method
    func tapHandler(sender: NSObject) {
        if sender.accessibilityHint == "AboutMe" {
            if self.view.subviews.contains(self.transperentView) {
                self.transperentView.removeFromSuperview()
            }
        } else {
            if self.view.subviews.contains(self.vwImage) {
                self.vwImage.removeFromSuperview()
            } else {
                self.view.addSubview(self.vwImage)
            }
        }

    }
    
    func rate(notification: NSNotification) {
        switch notification.userInfo!["ratings"]! as! Int {
        case 1:
            self.lblRatings.text = "Poor"
            break
        case 2:
            self.lblRatings.text = "Average"
            break
        case 3:
            self.lblRatings.text = "Good"
            break
        case 4:
            self.lblRatings.text = "Very Good"
            break
        case 5:
            self.lblRatings.text = "Excellent"
            break
        default:
            self.lblRatings.text = ""
            break
        }
        UserDetailVC.rate = (notification.userInfo!["ratings"]! as! Int)
        if UserDetailVC.rate > 0 {
            self.btnSubmit.isEnabled = true
            self.btnSubmit.alpha = 1.0
        } else {
            self.btnSubmit.isEnabled = false
            self.btnSubmit.alpha = 0.6
        }
    }
}

@IBDesignable class RatingControl: UIStackView {
    
    private var ratingButtons = [UIButton]()
    
    var rating = 0 {
        didSet {
            updateButtonSelectionStates()
        }
    }
    
    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0) {
        didSet {
            setupButtons()
        }
    }
    
    @IBInspectable var starCount: Int = 5 {
        didSet {
            setupButtons()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    
    //MARK: Button Action
    func ratingButtonTapped(button: UIButton) -> Int {
        guard let index = ratingButtons.index(of: button) else {
            fatalError("The button, \(button), is not in the ratingButtons array: \(ratingButtons)")
        }
        
        let selectedRating = index + 1
        
        if selectedRating == rating {
            rating = 0
        } else {
            rating = selectedRating
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "rate"), object: nil, userInfo: ["ratings": rating])
        return rating
    }
    
    //MARK: Custom Methods
    private func setupButtons() {
        
        self.rating = UserDetailVC.rate
        for button in ratingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        ratingButtons.removeAll()
        
        let bundle = Bundle(for: type(of: self))
        let filledStar = UIImage(named: "filledStar", in: bundle, compatibleWith: self.traitCollection)
        let emptyStar = UIImage(named:"emptyStar", in: bundle, compatibleWith: self.traitCollection)
        let highlightedStar = UIImage(named:"highlightedStar", in: bundle, compatibleWith: self.traitCollection)
        
        for index in 0..<starCount {
            let button = UIButton()
            
            button.setImage(emptyStar, for: .normal)
            button.setImage(filledStar, for: .selected)
            button.setImage(highlightedStar, for: .highlighted)
            button.setImage(highlightedStar, for: [.highlighted, .selected])
            
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            
            button.accessibilityLabel = "Set \(index + 1) star rating"
            
            button.addTarget(self, action: #selector(RatingControl.ratingButtonTapped(button:)), for: .touchUpInside)
            
            addArrangedSubview(button)
            
            ratingButtons.append(button)
        }
        updateButtonSelectionStates()
    }
    
    private func updateButtonSelectionStates() {
        for (index, button) in ratingButtons.enumerated() {
            button.isSelected = index < rating
            
            let hintString: String?
            if rating == index + 1 {
                hintString = "Tap to reset the rating to zero."
            } else {
                hintString = nil
            }
            
            let valueString: String
            switch (rating) {
            case 0:
                valueString = "No rating set."
            case 1:
                valueString = "1 star set."
            default:
                valueString = "\(rating) stars set."
            }
            
            button.accessibilityHint = hintString
            button.accessibilityValue = valueString
        }
    }
}
