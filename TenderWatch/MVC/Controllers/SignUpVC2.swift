//
//  SignUpVC.swift
//  TestApp
//
//  Created by Developer88 on 6/19/17.
//  Copyright © 2017 Developer88. All rights reserved.
//

import UIKit
import Alamofire
import RSKImageCropper
import IQKeyboardManager

class SignUpVC2: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, RSKImageCropViewControllerDelegate, UITextFieldDelegate {
    
    var picker : UIImagePickerController!
    
    @IBOutlet var mainvw: UIView!
    @IBOutlet weak var phonenum: UITextField!
    @IBOutlet weak var occupation: UITextField!
    @IBOutlet weak var btnnext: UIButton!
    @IBOutlet weak var proflPic: UIButton!
    @IBOutlet var btnCountry: UIButton!
    @IBOutlet var back: UIButton!
    @IBOutlet var opnDrawr: UIButton!
    @IBOutlet weak var lblName: UILabel!
    
    static var cName: String!
    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        IQKeyboardManager.shared().previousNextDisplayMode = .alwaysShow
        
        self.phonenum.delegate = self
        self.occupation.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapHandler))
        self.mainvw.addGestureRecognizer(tap)
        picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        image = self.proflPic.currentImage
        
    }
    
    override func viewDidLayoutSubviews() {
        self.btnnext.cornerRedius()
        proflPic.layer.cornerRadius = proflPic.frame.width / 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (USER?.authenticationToken != nil) {
            self.back.isHidden = true
            self.opnDrawr.isHidden = false
            self.lblName.isHidden = false
        } else {
            self.back.isHidden = false
            self.opnDrawr.isHidden = true
            self.lblName.isHidden = true
        }
        
        
        
        self.navigationController?.isNavigationBarHidden = true
        if (SignUpVC2.cName != nil) {
            self.btnCountry.setTitle(SignUpVC2.cName!, for: .normal)
            signUpUser.country = SignUpVC2.cName!
        }
    }
    
    //MARK :- TextField Delegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField == self.phonenum) {
            textField.keyboardType = UIKeyboardType.numberPad
        } else {
            textField.keyboardType = UIKeyboardType.default
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == self.phonenum) {
            textField.resignFirstResponder()
            self.occupation.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            self.btnCountry.becomeFirstResponder()
        }
        return true
    }
    
    //Mark:- Picker Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image : UIImage = (info[UIImagePickerControllerOriginalImage] as? UIImage)!
        
        picker.dismiss(animated: false, completion: { () -> Void in
            
            var imageCropVC : RSKImageCropViewController!
            
            imageCropVC = RSKImageCropViewController(image: image, cropMode: RSKImageCropMode.square)
            
            imageCropVC.delegate = self
            
            self.navigationController?.pushViewController(imageCropVC, animated: true)
            
        })
        
    }
    
    //Mark:- Crop delegates
    
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
        self.proflPic.setImage(croppedImage, for: .normal)
        let imgData = UIImageJPEGRepresentation(croppedImage, 0.2)
        signUpUser.photo = imgData
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- Custom Method
    
    func tapHandler() {
        self.occupation.resignFirstResponder()
        self.phonenum.resignFirstResponder()
    }
    
    //MARK: - Button CLick
    
    @IBAction func selectCountry(_ sender: Any) {
        self.navigationController?.pushViewController(RegisterCountryVC(), animated: true)
    }
    
    @IBAction func handleBtnnext(_ sender: Any) {
        if !(isValidNumber(self.phonenum.text!, length: 10)) {
            MessageManager.showAlert(nil, "Invalid Number")
        } else if (self.proflPic.currentImage == self.image) {
            MessageManager.showAlert(nil, "Choose a profile picture")
        } else {
            if (appDelegate.isClient)! {
                self.navigationController?.pushViewController(RulesVC(), animated: true)
            } else {
                self.navigationController?.pushViewController(MappingVC(), animated: true)
            }
            signUpUser.contactNo = self.phonenum.text!
            signUpUser.occupation = self.occupation.text!
        }
    }
    
    @IBAction func setProfilePic(_ sender: Any) {
        let option = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            
        }
        
        let galleryAction = UIAlertAction(title: "Gallery", style: .default) { (action) in
            self.present(self.picker, animated: true, completion: nil)
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        option.addAction(cameraAction)
        option.addAction(galleryAction)
        option.addAction(cancelAction)
        self.present(option, animated: true, completion: nil)
    }
    
    @IBAction func back(_ sender: Any) {
        
        if (USER?.authenticationToken != nil) {
            appDelegate.drawerController.toggleDrawerSide(.left, animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    @IBAction func handleAboutMe(_ sender: Any) {
        self.navigationController?.pushViewController(AboutVC(), animated: true)
    }
    
}
