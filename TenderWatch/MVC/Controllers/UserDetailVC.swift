//
//  UserDetailVC.swift
//  TenderWatch
//
//  Created by devloper65 on 8/10/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit
import SDWebImage

class UserDetailVC: UIViewController {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var txfEmail: UITextField!
    @IBOutlet weak var txfMobileNo: UITextField!
    @IBOutlet weak var txfOccupation: UITextField!
    @IBOutlet weak var txfCountry: UITextField!
    @IBOutlet weak var btnAboutMe: UIButton!
    @IBOutlet weak var vwStack: RatingControl!
    @IBOutlet weak var btnCancel: UIButton!
    
    @IBOutlet weak var lblRatings: UILabel!
    
    @IBOutlet weak var btnSubmit: UIButton!
    var ClientDetail: TenderDetail!
    var ContractorDetail: Notification!
    var rate: Int = 0
    var transperentView = UIView()
    var txtVw = UITextView()
    
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
        self.btnAboutMe.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        
        NotificationCenter.default.addObserver(self, selector: #selector(rate(notification:)), name: NSNotification.Name(rawValue : "rate"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.imgUser.layer.cornerRadius = self.imgUser.frame.height / 2
        self.navigationController?.isNavigationBarHidden = true
        
        self.imgUser.sd_setImage(with: !(appDelegate.isClient!) ? URL(string: (self.ClientDetail.tenderUploader?.profilePhoto)!) : URL(string: (self.ContractorDetail.sender?.profilePhoto)!), placeholderImage: nil, options: SDWebImageOptions.progressiveDownload) { (image, error, memory, url) in
        }
        
        self.txfEmail.text = !(appDelegate.isClient!) ? self.ClientDetail.tenderUploader?.email : self.ContractorDetail.sender?.email
        
        self.txfCountry.text = !(appDelegate.isClient!) ? self.ClientDetail.tenderUploader?.country : self.ContractorDetail.sender?.country
        
        self.txfMobileNo.text = !(appDelegate.isClient!) ? self.ClientDetail.tenderUploader?.contactNo : self.ContractorDetail.sender?.contactNo
        
        self.txfOccupation.text = !(appDelegate.isClient!) ? self.ClientDetail.tenderUploader?.occupation : self.ContractorDetail.sender?.occupation
        
        self.txtVw.text = !(appDelegate.isClient!) ? self.ClientDetail.tenderUploader?.aboutMe : self.ContractorDetail.sender?.aboutMe
    }
    
    override func viewDidLayoutSubviews() {
        self.transperentView.frame = self.view.frame
        self.txtVw.frame = CGRect(x: self.view.frame.width / 2 - 130, y: self.view.frame.height / 2 - 150, width: 260, height: 300)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //store rating
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func handleBtnAboutMe(_ sender: Any) {
        self.transperentView = UIView(frame: self.view.frame)
        self.transperentView.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.25)
        self.transperentView.addSubview(self.txtVw)
        if !self.view.subviews.contains(self.transperentView) {
            self.view.addSubview(self.transperentView)
        }
        let tapBtn = UITapGestureRecognizer(target: self, action: #selector(self.tapHandler))
        tapBtn.cancelsTouchesInView = false
        self.transperentView.addGestureRecognizer(tapBtn)
    }
    
    func tapHandler() {
        if self.view.subviews.contains(self.transperentView) {
            self.transperentView.removeFromSuperview()
        }
    }
    //MARK:- IBAction
    @IBAction func handleBtnRating(_ sender: Any) {
        print("submit")
    }
    
    @IBAction func handleBtnCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK:- Custom Method
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
            break
        }
        self.rate = (notification.userInfo!["ratings"]! as! Int)
        if rate > 0 {
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
