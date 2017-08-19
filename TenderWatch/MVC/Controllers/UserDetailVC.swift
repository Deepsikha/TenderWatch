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
    @IBOutlet weak var lblNoImage: UILabel!
    @IBOutlet weak var imgTender: UIImageView!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var txfEmail: UITextField!
    @IBOutlet weak var txfMobileNo: UITextField!
    @IBOutlet weak var txfOccupation: UITextField!
    @IBOutlet weak var txfCountry: UITextField!
    @IBOutlet weak var vwStack: RatingControl!
    @IBOutlet weak var btnCancel: UIButton!
    
    var ClientDetail: TenderDetail!
    var ContractorDetail: Notification!
    static var rate: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !(appDelegate.isClient!) {
            self.lblTitle.text = "Client Detail"
        } else {
            self.lblTitle.text = "Contractor Detail"
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.imgUser.layer.cornerRadius = self.imgUser.frame.height / 2
        self.navigationController?.isNavigationBarHidden = true
        
       
        self.imgUser.sd_setImage(with: !(appDelegate.isClient!) ? URL(string: (self.ClientDetail.tenderUploader?.profilePhoto)!) : URL(string: (self.ContractorDetail.sender?.profilePhoto)!), placeholderImage: nil, options: SDWebImageOptions.progressiveDownload) { (image, error, memory, url) in
            if (image == nil) {
                self.lblNoImage.isHidden = false
            }
        }

        self.imgTender.sd_setImage(with: !(appDelegate.isClient!) ? URL(string: (self.ClientDetail.tenderPhoto)!) : URL(string: (self.ContractorDetail.tender?.tenderPhoto)!), placeholderImage: nil, options: SDWebImageOptions.progressiveDownload) { (image, error, memory, url) in
        }
        self.txfEmail.text = !(appDelegate.isClient!) ? self.ClientDetail.tenderUploader?.email : self.ContractorDetail.sender?.email
        
        self.txfCountry.text = !(appDelegate.isClient!) ? self.ClientDetail.tenderUploader?.country : self.ContractorDetail.sender?.country
        
        self.txfMobileNo.text = !(appDelegate.isClient!) ? self.ClientDetail.tenderUploader?.contactNo : self.ContractorDetail.sender?.contactNo
        
        self.txfOccupation.text = !(appDelegate.isClient!) ? self.ClientDetail.tenderUploader?.occupation : self.ContractorDetail.sender?.occupation
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //store rating
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func handleBtnCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
    func ratingButtonTapped(button: UIButton) {
        guard let index = ratingButtons.index(of: button) else {
            fatalError("The button, \(button), is not in the ratingButtons array: \(ratingButtons)")
        }
        
        let selectedRating = index + 1
        
        if selectedRating == rating {
            rating = 0
        } else {
            rating = selectedRating
        }
        UserDetailVC.rate = rating
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
