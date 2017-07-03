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
import ObjectMapper

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
    var parameters : [String : Any]!
    
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
            self.btnnext.setTitle("Update", for: .normal)
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
            if (USER?.authenticationToken != nil) {
                signUpUser.contactNo = self.phonenum.text!
                signUpUser.occupation = self.occupation.text!
                self.update((USER?._id)!)
            } else {
                if (appDelegate.isClient)! {
                    self.navigationController?.pushViewController(RulesVC(), animated: true)
                } else {
                    self.navigationController?.pushViewController(MappingVC(), animated: true)
                }
            }
            
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
    
    func update(_ id: String) {
        
        if (appDelegate.isClient)! {
            self.parameters = ["country": signUpUser.country,
                               "contactNo": signUpUser.contactNo,
                               "occupation": signUpUser.occupation,
                               "aboutMe": signUpUser.aboutMe,
                               "role" : "client"] as [String : Any]
        } else {
            self.parameters = ["country": signUpUser.country,
                               "contactNo": signUpUser.contactNo,
                               "occupation": signUpUser.occupation,
                               "aboutMe": signUpUser.aboutMe,
                               "role" : "contractor"] as [String : Any]
        }
        if isNetworkReachable() {
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                if signUpUser.photo != nil
                {
                    let dated :NSDate = NSDate()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyyMMddHHmmssSSS"
                    dateFormatter.timeZone = NSTimeZone(name: "GMT")! as TimeZone
                    
                    let imgname = (dateFormatter.string(from: dated as Date)).appending(String(0) + ".jpg")
                    
                    multipartFormData.append(signUpUser.photo!, withName: "fileset",fileName: imgname, mimeType: "image/jpg")
                }
                for (key, value) in self.parameters {
                    multipartFormData.append((value as AnyObject).data(using: UInt(String.Encoding.utf8.hashValue))!, withName: key)
                }
            }, usingThreshold: 0, to: "http://192.168.200.22:4040/api/users/\(id)", method: HTTPMethod.post, headers: ["Authorization":"Bearer \(UserManager.shared.user!.authenticationToken!)"]) { (result) in
                switch result {
                case .success(let upload, _, _):
                    
                    upload.uploadProgress(closure: { (progress) in
                        print("Upload Progress: \(progress.fractionCompleted)")
                    })
                    
                    upload.responseJSON { resp in
                        if (resp.result.value != nil) {
                            print(resp.result.value!)
                            if (((resp.result.value as! NSDictionary).allKeys[0] as! String) == "error") {
                                MessageManager.showAlert(nil, "Invalid Credentials")
                            } else {
                                let data = (resp.result.value as! NSObject)
                                //data parsing remianing because of unique response
                                //                            USER = Mapper<User>().map(JSON: data as! [String : Any])!
                                
                                appDelegate.setHomeViewController()
                            }
                        }
                    }
                    
                case .failure(let encodingError):
                    print(encodingError)
                }
            }
        } else {
            MessageManager.showAlert(nil, "No Internet")
        }
        
    }
}
