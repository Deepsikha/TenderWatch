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
 import SDWebImage
 
 class SignUpVC2: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, RSKImageCropViewControllerDelegate, UITextFieldDelegate {
    
    var picker : UIImagePickerController!
    
    @IBOutlet var mainvw: UIView!
    @IBOutlet weak var phonenum: UITextField!
    @IBOutlet weak var occupation: UITextField!
    @IBOutlet var btnnext: UIButton!
    @IBOutlet weak var proflPic: UIButton!
    @IBOutlet var btnCountry: UIButton!
    @IBOutlet var back: UIButton!
    @IBOutlet var opnDrawr: UIButton!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblCountryCode: UILabel!
    
    var image: UIImage!
    var parameters : [String : Any]!
    static var isUpdated = false
    static var updated = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btnnext.isEnabled = false
        self.btnnext.alpha = 0.5
        IQKeyboardManager.shared().previousNextDisplayMode = .alwaysShow
        
        self.phonenum.delegate = self
        self.occupation.delegate = self
        
        self.phonenum.autocorrectionType = .no
        self.occupation.autocorrectionType = .no
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapHandler))
        self.mainvw.addGestureRecognizer(tap)
        
        picker = UIImagePickerController()
        picker.delegate = self
        
        if !signUpUser.photo.isEmpty {
            self.proflPic.setImage(UIImage(data: signUpUser.photo), for: .normal)
        }
        
        if (USER?.authenticationToken != nil) {
            self.back.isHidden = true
            self.opnDrawr.isHidden = false
            self.lblName.isHidden = false
            self.btnnext.setTitle("Update", for: .normal)
            self.btnCountry.setTitle(USER!.country!, for: .normal)
            self.lblCountryCode.text = USER?.contactNo?.components(separatedBy: "-").first
            self.phonenum.text = USER?.contactNo?.components(separatedBy: "-").last
            self.occupation.text = USER?.occupation
            self.proflPic.imageView?.sd_setShowActivityIndicatorView(true)
            self.proflPic.imageView?.sd_setIndicatorStyle(.gray)
            self.proflPic.imageView?.sd_setImage(with: URL(string: (USER?.profilePhoto)!), placeholderImage: UIImage(named: "avtar"), options: SDWebImageOptions.progressiveDownload, completed: { (image, error, memory, url) in
                if image == nil {
                    self.proflPic.setImage(UIImage(named: "avtar"), for: .normal)
                } else {
                    self.proflPic.setImage(image, for: .normal)
                }
            })
        } else {
            self.back.isHidden = false
            self.opnDrawr.isHidden = true
            self.lblName.isHidden = true
            self.proflPic.layer.borderColor = UIColor.black.cgColor
            self.proflPic.layer.borderWidth = 1
        }
    }
    
    override func viewDidLayoutSubviews() {
        self.btnnext.cornerRedius()
        proflPic.layer.cornerRadius = proflPic.frame.width / 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        if (USER?.authenticationToken == nil) {
            if (signUpUser.country.isEmpty) {
                self.btnCountry.setTitle("Country", for: .normal)
                self.lblCountryCode.text = "CC"
            } else {
                self.btnCountry.setTitle(signUpUser.country, for: .normal)
                self.lblCountryCode.text = RegisterCountryVC.countryCode
            }
        } else {
            if !(btnCountry.titleLabel!.text! == USER!.country!) {
                self.btnnext.isEnabled = true
                self.btnCountry.setTitle(USER!.country!, for: .normal)
                self.lblCountryCode.text = RegisterCountryVC.countryCode
                self.btnnext.alpha = 1.0
            }
            if !(signUpUser.contactNo.isEmpty) {
                self.phonenum.text = signUpUser.contactNo.components(separatedBy: "-").last!
            } else if !(signUpUser.occupation.isEmpty) {
                self.occupation.text = signUpUser.occupation
            }
        }
        
        if(SignUpVC2.isUpdated) {
            self.btnnext.isEnabled = true
            self.btnnext.alpha = 1.0
        } else {
            if self.btnnext.isEnabled  {
                self.btnnext.isEnabled = true
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if(SignUpVC2.updated) {
            self.btnnext.alpha = 0.5
            SignUpVC2.isUpdated = false
        }
    }
    
    //MARK:- TextField Delegate
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
        let imgData = UIImageJPEGRepresentation(croppedImage, 0.2)
        if(self.proflPic.currentImage == croppedImage) {
            self.btnnext.isEnabled = false
            self.btnnext.alpha = 0.5
        } else {
            self.btnnext.isEnabled = true
            self.btnnext.alpha = 1.0
        }
        signUpUser.photo = imgData!
        self.proflPic.setImage(croppedImage, for: .normal)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- IBActions
    
    @IBAction func change(_ sender: UITextField) {
        if(sender.text == USER?.contactNo || sender.text == USER?.occupation) {
            self.btnnext.isEnabled = false
            self.btnnext.alpha = 0.5
        } else {
            if(sender == self.phonenum) {
                if(sender.text?.characters.count == 9) {
                    self.btnnext.isEnabled = true
                    self.btnnext.alpha = 1.0
                } else {
                    self.btnnext.isEnabled = false
                    self.btnnext.alpha = 0.5
                    
                }
            } else if(sender == self.occupation && (sender.text?.characters.count != 0) ) {
                self.btnnext.alpha = 1.0
                self.btnnext.isEnabled = true
            }
        }
    }
    
    @IBAction func selectCountry(_ sender: Any) {
        self.navigationController?.pushViewController(RegisterCountryVC(), animated: true)
    }
    
    @IBAction func handleBtnnext(_ sender: Any) {
        if !(isValidNumber(self.phonenum.text!, length: 9)) {
            MessageManager.showAlert(nil, "Invalid Number")
        } else {
            if (USER?.authenticationToken != nil) {
                USER?.contactNo = (USER?.contactNo?.components(separatedBy: "-").first)! + "-" + self.phonenum.text!
                USER?.occupation = self.occupation.text!
                USER?.aboutMe = (USER?.aboutMe)!
                USER?.country = (self.btnCountry.titleLabel?.text)!
                if signUpUser.photo.isEmpty {
                    signUpUser.photo = UIImageJPEGRepresentation(UIImage(named: "avtar")!, 0.2)!
                }
                self.update()
            } else {
                if (appDelegate.isClient)! {
                    self.navigationController?.pushViewController(RulesVC(), animated: true)
                } else {
                    self.navigationController?.pushViewController(SelectCountryVC(), animated: true)
                }
                signUpUser.contactNo = RegisterCountryVC.countryCode + "-" + self.phonenum.text!
                signUpUser.occupation = self.occupation.text!
                if signUpUser.photo.isEmpty {
                    signUpUser.photo = UIImageJPEGRepresentation(UIImage(named: "avtar")!, 0.2)!
                }
            }
        }
    }
    
    @IBAction func setProfilePic(_ sender: Any) {
        let option = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.picker.sourceType = UIImagePickerControllerSourceType.camera
            self.present(self.picker, animated: true, completion: nil)
            
        }
        
        let galleryAction = UIAlertAction(title: "Gallery", style: .default) { (action) in
            self.picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            
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
    
    //MARK:- Custom Method
    func update() {
        self.parameters = ["country": USER?.country! as Any,
                           "contactNo": USER?.contactNo! as Any,
                           "occupation": USER?.occupation! as Any,
                           "aboutMe": USER?.aboutMe! as Any,
                           "role" : appDelegate.isClient! ? "client" : "contractor"]
        
        if isNetworkReachable() {
            self.startActivityIndicator()
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                if !(signUpUser.photo.isEmpty)
                {
                    let dated :NSDate = NSDate()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyyMMddHHmmssSSS"
                    dateFormatter.timeZone = NSTimeZone(name: "GMT")! as TimeZone
                    
                    let imgname = (dateFormatter.string(from: dated as Date)).appending(String(0) + ".jpg")
                    
                    multipartFormData.append(signUpUser.photo, withName: "image",fileName: imgname, mimeType: "image/jpeg")
                }
                for (key, value) in self.parameters {
                    multipartFormData.append((value as AnyObject).data(using: UInt(String.Encoding.utf8.hashValue))!, withName: key)
                }
            }, usingThreshold: 0, to: (BASE_URL)+"users/"+(USER?._id)!, method: HTTPMethod.post, headers: ["Authorization":"Bearer \(UserManager.shared.user!.authenticationToken!)"]) { (result) in
                switch result {
                case .success(let upload, _, _):
                    
                    upload.uploadProgress(closure: { (progress) in
                        print("Upload Progress: \(progress.fractionCompleted)")
                    })
                    
                    upload.responseJSON { resp in
                        if (resp.result.value != nil) {
                            print(resp.result.value!)
                            if  ((resp.result.value as! NSDictionary).allKeys.contains(where: { (a) -> Bool in
                                if (a as! String) == "error" {
                                    return true
                                } else {
                                    return false
                                }
                            })) {
                                MessageManager.showAlert(nil, (resp.result.value as! NSObject).value(forKey: "error") as! String)
                                self.stopActivityIndicator()
                            } else {
                                SignUpVC2.updated = true
                                let data = (resp.result.value as! NSObject)
                                let token = USER?.authenticationToken
                                USER = Mapper<User>().map(JSON: data as! [String : Any])!
                                USER?.authenticationToken = token
                                self.stopActivityIndicator()
                                appDelegate.setHomeViewController()
                            }
                        }
                    }
                    
                case .failure(let encodingError):
                    print(encodingError)
                    self.stopActivityIndicator()
                }
            }
        } else {
            MessageManager.showAlert(nil, "No Internet")
            self.stopActivityIndicator()
        }
    }
    
    func tapHandler() {
        self.occupation.resignFirstResponder()
        self.phonenum.resignFirstResponder()
    }
 }
