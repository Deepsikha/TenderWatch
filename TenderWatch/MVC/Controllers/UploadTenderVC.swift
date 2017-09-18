//
//  UploadTenderVC.swift
//  TenderWatch
//
//  Created by Developer88 on 6/28/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import RSKImageCropper
import SDWebImage

class UploadTenderVC: UIViewController,UITableViewDelegate,UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate, RSKImageCropViewControllerDelegate {
    
    @IBOutlet weak var opnDrwr: UIButton!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var txfTenderTitle: UITextField!
    @IBOutlet weak var vwScroll: UIScrollView!
    @IBOutlet weak var btnImage: UIButton!
    @IBOutlet weak var lblDropdown: UILabel!
    @IBOutlet weak var lblDropdownCat: UILabel!
    @IBOutlet weak var tenderDetail: UITextView!
    @IBOutlet weak var btnSelectCountry: UIButton!
    @IBOutlet weak var btnSelectCategory: UIButton!
    @IBOutlet weak var btnContact: UIButton!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var vwSelectCountry: UIView!
    @IBOutlet weak var vwSelectCategory: UIView!
    @IBOutlet weak var vwMain: UIView!
    @IBOutlet var vwContactPopup: UIView!
    @IBOutlet var tblOptions: UITableView!
    @IBOutlet weak var txfEmail: UITextField!
    @IBOutlet weak var txfMobileNo: UITextField!
    @IBOutlet weak var txfLandLineNo: UITextField!
    @IBOutlet weak var txtvwAddress: UITextView!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var const_vwMain_height: NSLayoutConstraint!
    @IBOutlet weak var vwBlur: UIView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnFollow: UIButton!
    
    @IBOutlet weak var btnCancel: UIButton!
    let checkedImage = UIImage(named: "chaboxcheked")! as UIImage
    let uncheckedImage = UIImage(named: "chabox")! as UIImage
    var isChecked: Bool = false
    
    var arrDropDown = [String]()
    var tender = [Tender]()
    var country = [Country]()
    var category = [Category]()
    var uploadTender = UploadTender()
    var picker: UIImagePickerController!
    var isCountry = true
    var isDropDownActive = false
    var tap: UITapGestureRecognizer!
    static var isUpdate: Bool = false
    static var id: String!
    var updateCId: String!
    var updateCtId: String!
    var update: TenderDetail!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerNib()
        
        picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        //let tap = UITapGestureRecognizer(target: self, action: #selector(self.mainTap))
        //tap.cancelsTouchesInView = false
        //self.view.addGestureRecognizer(tap)
        self.tblOptions.tableFooterView = UIView()
        
        self.btnContact.setTitle((self.btnContact.titleLabel!.text)!+"   ▼   ", for: .normal)
        if UploadTenderVC.isUpdate {
            self.getDetail()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.isNavigationBarHidden = true
        if (UploadTenderVC.isUpdate) {
            self.opnDrwr.isHidden = true
            self.btnCancel.isHidden = true
            self.btnBack.isHidden = false
            self.lblName.text = "Amend Tender"
            self.btnSubmit.setTitle("Amend", for: .normal)
        } else {
            self.opnDrwr.isHidden = false
            self.btnCancel.isHidden = false
            self.btnBack.isHidden = true
            self.lblName.text = "Upload Tender"
            self.btnSubmit.setTitle("Upload Tender", for: .normal)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        if isCountry {
            self.tblOptions.frame = CGRect(x: self.vwSelectCountry.frame.origin.x, y: self.vwScroll.frame.origin.y + self.vwSelectCountry.frame.origin.y + self.vwSelectCountry.frame.height, width: self.vwSelectCountry.frame.width, height: 220)
        } else {
            self.tblOptions.frame = CGRect(x: self.vwSelectCategory.frame.origin.x, y: self.vwScroll.frame.origin.y + self.vwSelectCategory.frame.origin.y + self.vwSelectCategory.frame.height, width: self.vwSelectCategory.frame.width, height: 220)
        }
        self.vwContactPopup.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        let widthVwmain = btnImage.frame.size.height
        const_vwMain_height.constant = 507 + widthVwmain
    }
    
    //MARK:- TextField Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if UploadTenderVC.isUpdate {
            if (self.btnSelectCategory.titleLabel?.text?.isEmpty)! && (self.btnSelectCountry.titleLabel?.text?.isEmpty)! {
                MessageManager.showAlert(nil, "Select Country & Category First")
            }
        } else {
            if (self.country.count == 0) && (self.category.count == 0) {
                MessageManager.showAlert(nil, "Select Country & Category First")
            }
        }
        self.mainTap()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.txfEmail {
            textField.resignFirstResponder()
            self.txfMobileNo.becomeFirstResponder()
            return true
        } else if textField == self.txfMobileNo {
            textField.resignFirstResponder()
            self.txfLandLineNo.becomeFirstResponder()
            return true
        } else if textField == self.txfLandLineNo {
            textField.resignFirstResponder()
            self.txtvwAddress.becomeFirstResponder()
            return true
        } else {
            textField.resignFirstResponder()
            self.tenderDetail.becomeFirstResponder()
            return false
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField == self.txfEmail {
            self.uploadTender.email = textField.text!
        } else if textField == self.txfMobileNo {
            self.uploadTender.contactNo = textField.text!
        } else if textField == self.txfLandLineNo {
            self.uploadTender.landLineNo = textField.text!
        } else if textField == self.txfTenderTitle {
            self.uploadTender.tenderTitle = textField.text!
        }
        return true
    }
    
    //MARK:- TextView Delegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.mainTap()
        if textView == self.txtvwAddress {
            if !(self.txtvwAddress.text.isEmpty) {
                if textView.text == "Address" {
                    textView.text = ""
                    textView.textColor = UIColor.black
                }
            }
        } else if textView == self.tenderDetail {
            if !(self.txtvwAddress.text.isEmpty) {
                if textView.text == "Enter description of Tender" {
                    textView.text = ""
                    textView.textColor = UIColor.black
                }
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if (textView == self.tenderDetail) {
            if textView.text.isEmpty {
                textView.text = "Enter description of Tender"
                textView.textColor = UIColor.lightGray
                self.uploadTender.desc = ""
            } else {
                self.uploadTender.desc = textView.text!
            }
        } else if (textView == self.txtvwAddress) {
            if textView.text.isEmpty {
                textView.text = "Address"
                textView.textColor = UIColor.lightGray
                self.uploadTender.address = ""
            } else {
                self.uploadTender.address = textView.text!
            }
        }
    }
    
    // MARK:- Tableview Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isCountry {
            return self.country.count
        } else {
            return self.category.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MappingCell") as! MappingCell
        if isCountry {
            let country = self.country[indexPath.row]
            cell.lblCategory.text = country.countryName!
        } else {
            let category = self.category[indexPath.row]
            cell.lblCategory.text = category.categoryName!
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! MappingCell
        if (isCountry) {
            btnSelectCountry.setTitle(cell.lblCategory.text!, for: .normal)
            lblDropdown.text = "▼"
            self.uploadTender.cId = self.country.filter{$0.countryName! == cell.lblCategory.text!}[0].countryId!
        }else{
            btnSelectCategory.setTitle(cell.lblCategory.text!, for: .normal)
            lblDropdownCat.text = "▼"
            self.uploadTender.ctId = self.category.filter {$0.categoryName! == cell.lblCategory.text!}[0].categoryId!
        }
        self.tblOptions.removeFromSuperview()
        self.vwScroll.isScrollEnabled = true
        isDropDownActive = false
    }
    
    //MARK:- Image Delegate
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
        self.btnImage.setImage(croppedImage, for: .normal)
        let imgData = UIImageJPEGRepresentation(croppedImage, 0.2)
        self.uploadTender.photo = imgData!
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // MARK:- IBActions
    @IBAction func handleOpenDrwr(_ sender: Any) {
        appDelegate.drawerController.toggleDrawerSide(.left, animated: true, completion: nil)
    }
    
    @IBAction func btnSelectCountry(_ sender: Any) {
        if isDropDownActive == false{
            self.isCountry = true
            lblDropdown.text = "▲"
            self.vwScroll.isScrollEnabled = false
            self.view.addSubview(self.tblOptions)
            if self.country.count == 0 {
                self.fetchCountry()
            }
            self.tblOptions.reloadData()
            self.isDropDownActive = true
        }else{
            lblDropdown.text = "▼"
            self.vwScroll.isScrollEnabled = true
            tblOptions.removeFromSuperview()
            self.isDropDownActive = false
        }
        
    }
    
    @IBAction func btnSelectCategory(_ sender: Any) {
        if isDropDownActive == false{
            self.isCountry = false
            self.vwScroll.isScrollEnabled = false
            lblDropdownCat.text = "▲"
            self.view.addSubview(self.tblOptions)
            if self.category.count == 0 {
                self.fetchCategory()
            }
            self.tblOptions.reloadData()
            self.isDropDownActive = true
        }else{
            lblDropdownCat.text = "▼"
            self.vwScroll.isScrollEnabled = true
            tblOptions.removeFromSuperview()
            self.isDropDownActive = false
        }
        
    }
    
    @IBAction func btnShowContactPopup(_ sender: Any) {
        self.mainTap()
        if UploadTenderVC.isUpdate {
            if (self.btnSelectCategory.titleLabel?.text?.isEmpty)! && (self.btnSelectCountry.titleLabel?.text?.isEmpty)! {
                MessageManager.showAlert(nil, "Select Country & Category First")
            }  else {
                self.view.addSubview(vwContactPopup)
                self.tap = UITapGestureRecognizer(target: self, action: #selector(self.taphandler))
                tap.cancelsTouchesInView = false
                
                self.vwBlur.addGestureRecognizer(tap)
                self.txtvwAddress.textColor = self.txtvwAddress.text.isEmpty ? UIColor.lightGray : UIColor.black
            }
        } else {
            if (self.country.count == 0) && (self.category.count == 0) {
                MessageManager.showAlert(nil, "Select Country & Category First")
            }  else {
                self.view.addSubview(vwContactPopup)
                self.tap = UITapGestureRecognizer(target: self, action: #selector(self.taphandler))
                tap.cancelsTouchesInView = false
                
                self.vwBlur.addGestureRecognizer(tap)
            }
        }
    }
    
    @IBAction func sbmt(_ sender: Any) {
        if (UploadTenderVC.isUpdate) {
            let parameter: Parameters = [
                "country":(self.country.count == 0) ? self.updateCId! :self.uploadTender.cId,
                "category":(self.category.count == 0) ? self.updateCtId! : self.uploadTender.ctId,
                "tenderName":self.txfTenderTitle.text!,
                "description":self.tenderDetail.text!,
                "email": self.uploadTender.email,
                "landlineNo": self.uploadTender.landLineNo,
                "contactNo": self.uploadTender.contactNo,
                "address": self.uploadTender.address,
                "isFollowTender": isChecked ? "true" : "false"]
            
            self.submit(UPLOAD_TENDER+"\(UploadTenderVC.id!)", .put, parameter, "Successfully Updated")
        } else {
            let parameter: Parameters = [  "country":self.uploadTender.cId,
                                           "category":self.uploadTender.ctId,
                                           "tenderName":self.uploadTender.tenderTitle,
                                           "description":self.uploadTender.desc,
                                           "email": self.uploadTender.email,
                                           "landlineNo": self.uploadTender.landLineNo,
                                           "contactNo": self.uploadTender.contactNo,
                                           "address": self.uploadTender.address,
                                           "isFollowTender": isChecked ? "true" : "false"]
            self.submit(UPLOAD_TENDER, .post, parameter, "Successfully Uploaded")
        }
        
    }
    
    @IBAction func handleBtnImage(_ sender: Any) {
        self.mainTap()
        let option = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.picker.sourceType = UIImagePickerControllerSourceType.camera
            self.present(self.picker, animated: true, completion: nil)
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
    
    @IBAction func handleBtnSave(_ sender: Any) {
        if !(self.txfEmail.text?.isEmpty)! || !(self.txfMobileNo.text?.isEmpty)! || !(self.txfLandLineNo.text?.isEmpty)! || (!(self.txtvwAddress.text == "Address") && !self.txtvwAddress.text.isEmpty) || self.btnFollow.imageView?.image == checkedImage {
            if !(self.txfEmail.text?.isEmpty)! && !(isValidEmail(strEmail: self.txfEmail.text!)) {
                MessageManager.showAlert(nil, "Enter valid Email")
            } else if !(self.txfMobileNo.text?.isEmpty)! && !(isValidNumber(self.txfMobileNo.text!, length: 9)) {
                MessageManager.showAlert(nil, "Enter valid Number")
            } else if !(self.txfLandLineNo.text?.isEmpty)! && !(isValidNumber(self.txfLandLineNo.text!, length: 7)) {
                MessageManager.showAlert(nil, "Enter valid LandLine Number")
            } else {
                self.vwContactPopup.removeFromSuperview()
            }
        } else {
            MessageManager.showAlert(nil, "at least one Field Manadatory")
        }
    }
    
    @IBAction func handleBtnBack(_ sender: Any) {
        UploadTenderVC.isUpdate = false
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func handleBtnFollow(_ sender: Any) {
        if(isChecked == true) {
            self.btnFollow.setImage(uncheckedImage, for: .normal)
            self.isChecked = !isChecked
        } else {
            self.btnFollow.setImage(checkedImage, for: .normal)
            self.isChecked = !isChecked
        }
    }
    @IBAction func handleBtnCancel(_ sender: Any) {
        appDelegate.setHomeViewController()
    }
    //MARK:- Custom Method
    func registerNib(){
        
        self.vwSelectCountry.layer.cornerRadius = 5
        self.vwSelectCategory.layer.cornerRadius = 5
        self.txfTenderTitle.layer.cornerRadius = 5
        self.btnContact.layer.cornerRadius = 5
        
        self.btnImage.layer.borderWidth = 1
        self.btnImage.layer.borderColor = UIColor.lightGray.cgColor
        self.btnImage.layer.cornerRadius = 5
        
        self.btnSubmit.cornerRedius()
        self.btnSave.cornerRedius()
        
        // control design formation
        self.tenderDetail.layer.cornerRadius = 5
        self.tenderDetail.layer.borderColor = UIColor.lightGray.cgColor
        self.tenderDetail.layer.borderWidth = 1
        self.txfTenderTitle.layer.borderColor = UIColor.lightGray.cgColor
        self.txfTenderTitle.layer.borderWidth = 1
        
        self.tblOptions.dataSource = self
        self.tblOptions.delegate = self
        
        self.txfTenderTitle.delegate = self
        self.tenderDetail.delegate = self
        
        self.txfEmail.delegate = self
        self.txfMobileNo.delegate = self
        self.txfLandLineNo.delegate = self
        self.txtvwAddress.delegate = self
        
        tblOptions.register(UINib(nibName: "MappingCell",bundle: nil), forCellReuseIdentifier: "MappingCell")
    }
    
    func submit(_ url: String, _ reqMethod: HTTPMethod, _ param: Parameters, _ message: String) {
        if !(UploadTenderVC.isUpdate) ? ((!(self.uploadTender.ctId.isEmpty) && !(self.uploadTender.cId.isEmpty) && !(self.txfTenderTitle.text?.isEmpty)!) && (!(self.txfEmail.text?.isEmpty)! || (!(self.txfMobileNo.text?.isEmpty)! && isValidNumber(self.txfMobileNo.text!, length: 9)) || !(self.txfLandLineNo.text?.isEmpty)! || (!(self.txtvwAddress.text == "Address") && !self.txtvwAddress.text.isEmpty) || self.btnFollow.imageView?.image == checkedImage)) : ((!(self.btnSelectCountry.titleLabel!.text!.isEmpty) && !(self.btnSelectCategory.titleLabel!.text!.isEmpty) && !(self.txfTenderTitle.text?.isEmpty)!) && (!(self.txfEmail.text?.isEmpty)! || (!(self.txfMobileNo.text?.isEmpty)! && isValidNumber(self.txfMobileNo.text!, length: 9)) || !(self.txfLandLineNo.text?.isEmpty)! || (!(self.txtvwAddress.text == "Address") && !self.txtvwAddress.text.isEmpty) || self.btnFollow.imageView!.image! == checkedImage)) {
            
            if isNetworkReachable() {
                self.startActivityIndicator()
                Alamofire.upload(multipartFormData: { (multipartFormData) in
                    if !(self.uploadTender.photo.isEmpty)
                    {
                        let dated :NSDate = NSDate()
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyyMMddHHmmssSSS"
                        dateFormatter.timeZone = NSTimeZone(name: "GMT")! as TimeZone
                        
                        let imgname = (dateFormatter.string(from: dated as Date)).appending(String(0) + ".jpg")
                        multipartFormData.append(self.uploadTender.photo, withName: "image",fileName: imgname, mimeType: "image/jpeg")
                    } else {
                        multipartFormData.append("no image".data(using: String.Encoding(rawValue: UInt(String.Encoding.utf8.hashValue)))!, withName: "tenderPhoto")
                    }
                
                    for (key, value) in param {
            
                        multipartFormData.append((value as AnyObject).data(using: UInt(String.Encoding.utf8.hashValue))!, withName: key)
                    }
                }, usingThreshold: 0, to: url, method: reqMethod, headers: ["Authorization":"Bearer \(UserManager.shared.user!.authenticationToken!)"]) { (result) in
                    switch result {
                    case .success(let upload, _, _):
                        
                        upload.uploadProgress(closure: { (progress) in
                            print("Upload Progress: \(progress.fractionCompleted)")
                        })
                        
                        upload.responseJSON { resp in
                            if (resp.result.value != nil) {
                                if ((resp.result.value as! NSDictionary).allKeys.contains(where: { (a) -> Bool in
                                    if (a as! String) == "error" {
                                        return true
                                    } else {
                                        return false
                                    }
                                })) {
                                    let err = (resp.result.value as! NSObject).value(forKey: "error") as! String
                                    MessageManager.showAlert(nil, "\(err)")
                                    self.stopActivityIndicator()
                                } else {
//                                    let data = (resp.result.value as! NSObject)
                                    //data parsing remianing because of unique response
                                    //                            USER = Mapper<User>().map(JSON: data as! [String : Any])!
                                    self.stopActivityIndicator()
                                    UploadTenderVC.isUpdate = false
                                    appDelegate.setHomeViewController()
                                    MessageManager.showAlert(nil, message)
                                    
                                }
                            } else {
                                self.stopActivityIndicator()
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
        } else {
            if (UploadTenderVC.isUpdate) ? self.btnSelectCountry.titleLabel!.text! == "Select Country" : self.uploadTender.cId.isEmpty {
                MessageManager.showAlert(nil, "Select Country")
            } else if (UploadTenderVC.isUpdate) ? self.btnSelectCategory.titleLabel!.text! == "Select Category" : self.uploadTender.ctId.isEmpty {
                MessageManager.showAlert(nil, "Select Category")
            } else if !(!(self.txfEmail.text?.isEmpty)! || (!(self.txfMobileNo.text?.isEmpty)! && isValidNumber(self.txfMobileNo.text!, length: 9)) || !(self.txfLandLineNo.text?.isEmpty)! || !(self.txtvwAddress.text == "Address")  || self.btnFollow.imageView!.image! == checkedImage){
                MessageManager.showAlert(nil, "Enter valid Contact Details")
            } else {
                MessageManager.showAlert(nil, "Enter Title")
            }
        }
    }
    
    func fetchCountry() {
        self.startActivityIndicator()
        APIManager.shared.requestForGET(url: COUNTRY, isTokenEmbeded: false, successHandler: { (finish, res) in
            if res.result.value != nil
            {
                let data = (res.result.value as! NSObject)
                self.country = Mapper<Country>().mapArray(JSONObject: data)!
                self.country = self.country.sorted(by: { (a, b) -> Bool in
                    a.countryName! < b.countryName!
                })
                self.stopActivityIndicator()
                self.tblOptions.reloadData()
            }
        }) { (errorMessage) in
            print(errorMessage)
        }
    }
    
    func fetchCategory() {
        self.startActivityIndicator()
        APIManager.shared.requestForGET(url: CATEGORY, isTokenEmbeded: false, successHandler: { (finish, res) in
            if res.result.value != nil
            {
                let data = (res.result.value as! NSObject)
                self.category = Mapper<Category>().mapArray(JSONObject: data)!
                self.category = self.category.sorted(by: { (a, b) -> Bool in
                    a.categoryName! < b.categoryName!
                })
                self.stopActivityIndicator()
                self.tblOptions.reloadData()
            }
            
        }) { (errorMessage) in
            print(errorMessage)
        }
    }
    
    func taphandler() {
        
        self.view.subviews.last?.removeFromSuperview()
        self.view.removeGestureRecognizer(tap)
    }
    
    func mainTap() {
        if (self.view.subviews.contains(tblOptions)) {
            self.tblOptions.removeFromSuperview()
            if (self.isCountry) {
                lblDropdown.text = "▼"
            } else {
                lblDropdownCat.text = "▼"
            }
            self.vwScroll.isScrollEnabled = true
            self.isDropDownActive = false
        }
    }
    
    
    func getDetail() {
        if isNetworkReachable() {
            self.startActivityIndicator()
            Alamofire.request(TENDER_DETAIL+"\(UploadTenderVC.id!)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(UserManager.shared.user!.authenticationToken!)"]).responseJSON(completionHandler: { (resp) in
                if(resp.result.value != nil) {
                    if ((resp.result.value as! NSDictionary).allKeys.contains(where: { (a) -> Bool in
                        if (a as! String) == "error" {
                            return true
                        } else {
                            return false
                        }
                    })) {
                        let err = (resp.result.value as! NSObject).value(forKey: "error")
                        MessageManager.showAlert(nil, "\(String(describing: err))")
                    } else {
                        let data = (resp.result.value as! NSObject)
                        self.update = Mapper<TenderDetail>().map(JSONObject: data)
                        
                        self.btnSelectCountry.setTitle(self.update.country!.countryName!, for: .normal)
                        self.updateCId = self.update.country!.countryId!
                        
                        self.btnSelectCategory.setTitle(self.update.category!.categoryName!, for: .normal)
                        self.updateCtId = self.update.category!.categoryId!
                        
                        self.txfTenderTitle.text = self.update.tenderName!
                        self.tenderDetail.text = self.update.desc!
                        self.tenderDetail.textColor = UIColor.black
                        
                        self.txfEmail.text = self.update.email!.isEmpty ? "" : self.update.email!
                        self.txfMobileNo.text = self.update.contactNo!.isEmpty ? "" : self.update.contactNo
                        self.txfLandLineNo.text = self.update.landlineNo!.isEmpty ? "" : self.update.landlineNo
                        self.txtvwAddress.text = self.update.address!.isEmpty ? "" : self.update.address
                        self.isChecked = self.update.isFollowTender!
                        if (self.isChecked) {
                            self.btnFollow.setImage(self.checkedImage, for: .normal)
                        } else {
                            self.btnFollow.setImage(self.uncheckedImage, for: .normal)

                        }
                        self.btnImage.imageView?.sd_setImage(with: URL(string: self.update.tenderPhoto!), placeholderImage: UIImage(named: "avtar"), options: SDWebImageOptions.progressiveDownload, completed: { (image, error, memory, url) in
                            if image == nil {
                                self.btnImage.setImage(UIImage(named: "avtar"), for: .normal)
                            } else {
                                self.btnImage.setImage(image, for: .normal)
                            }
                        })
                    }
                    self.stopActivityIndicator()
                }
            })
        } else {
            MessageManager.showAlert(nil, "No Internet")
        }
    }
}
