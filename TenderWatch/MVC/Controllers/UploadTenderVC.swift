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
    @IBOutlet weak var tempView: UIView!
    @IBOutlet var vwContactPopup: UIView!
    @IBOutlet var tblOptions: UITableView!
    
    var arrDropDown = [String]()
    var tender = [Tender]()
    var country = [Country]()
    var category = [Category]()
    var picker: UIImagePickerController!
    var isCountry = true
    
    var cId: String! //for country
    var ctId: String! //for categoty
    var tenderTitle: String!
    var desc: String!
    var photo: Data!
    
    var tap: UITapGestureRecognizer!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerNib()
        
        picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        //tapHandler
        self.tap = UITapGestureRecognizer(target: self, action: #selector(self.taphandler))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }

    override func viewWillAppear(_ animated: Bool) {
         self.navigationController?.isNavigationBarHidden = true
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
    }
    
    func registerNib(){
        
        self.vwSelectCountry.layer.cornerRadius = 5
        self.vwSelectCategory.layer.cornerRadius = 5
        self.vwContactPopup.layer.cornerRadius = 5
        self.txfTenderTitle.layer.cornerRadius = 5
        self.btnContact.layer.cornerRadius = 5
        self.btnSubmit.cornerRedius()
        
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
        
        tblOptions.register(UINib(nibName: "MappingCell",bundle: nil), forCellReuseIdentifier: "MappingCell")
        
    }
    
    //MARK: TextField Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (self.country.count == 0) && (self.category.count == 0) {
            MessageManager.showAlert(nil, "Select Country & Category First")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.tenderTitle = textField.text!
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.tenderTitle = textField.text!
        return true
    }
    //MARK: TextView Delegate
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.desc = textView.text!
    }
    // MARK:- Table view
    
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
            self.cId = self.country.filter{$0.countryName == cell.lblCategory.text!}[0].countryId
        }else{
            btnSelectCategory.setTitle(cell.lblCategory.text!, for: .normal)
            lblDropdownCat.text = "▼"
            self.ctId = self.category.filter {$0.categoryName == cell.lblCategory.text!}[0].categoryId
        }
        self.tblOptions.removeFromSuperview()
    }
    
    //MARK: Image Delegate
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
        self.photo = imgData
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // MARK:- IBActions
    
    @IBAction func handleOpenDrwr(_ sender: Any) {
        appDelegate.drawerController.toggleDrawerSide(.left, animated: true, completion: nil)
    }
    
    @IBAction func btnSelectCountry(_ sender: Any) {
        self.isCountry = true
        lblDropdown.text = "▲"
        
        self.view.addSubview(self.tblOptions)
        if self.country.count == 0 {
            self.fetchCoutry()
        }
        self.tblOptions.reloadData()
    }
    
    @IBAction func btnSelectCategory(_ sender: Any) {
        self.isCountry = false
        lblDropdownCat.text = "▲"
        self.view.addSubview(self.tblOptions)
        if self.category.count == 0 {
            self.fetchCategory()
        }
        self.tblOptions.reloadData()
    }
    
    @IBAction func btnShowContactPopup(_ sender: Any) {
        self.vwContactPopup.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        self.view.addSubview(vwContactPopup)
    }
    
    @IBAction func btnDoneHidePopup(_ sender: Any) {
        self.vwContactPopup.removeFromSuperview()
    }
    
    @IBAction func sbmt(_ sender: Any) {
        self.submit()
    }
    @IBAction func handleBtnImage(_ sender: Any) {
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
    
    func submit() {
        let param: Parameters = [  "country":self.cId!,
                       "category":self.ctId!,
                       "tenderName":self.tenderTitle!,
                       "description":self.desc!,
                       "email":"tender@gmail.com",
                       "landlineNo":"2522833",
                       "contactNo":"3648365448",
                       "address":"nthg"]
//        APIManager.shared.callRequestedAPI(url: "tender", method: .post, headers: ["Authorization":"Bearer \(UserManager.shared.user!.authenticationToken!)"], params: param, successHandler: { (true, resp) in
//            print(resp)
//        }) { (error) in
//            print(error)
//        }
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            if self.photo != nil
            {
                let dated :NSDate = NSDate()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyyMMddHHmmssSSS"
                dateFormatter.timeZone = NSTimeZone(name: "GMT")! as TimeZone
                
                let imgname = (dateFormatter.string(from: dated as Date)).appending(String(0) + ".jpg")
                multipartFormData.append(self.photo!, withName: "fileset",fileName: imgname, mimeType: "image/jpg")
            }
            for (key, value) in param {
                multipartFormData.append((value as AnyObject).data(using: UInt(String.Encoding.utf8.hashValue))!, withName: key)
            }
        }, usingThreshold: 0, to: "http://192.168.200.22:4040/api/tender", method: HTTPMethod.post, headers: ["Authorization":"Bearer \(UserManager.shared.user!.authenticationToken!)"]) { (result) in
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
    }
    
    func fetchCoutry()
    {
        self.startActivityIndicator()
        APIManager.shared.requestForGET(url: "auth/country", isTokenEmbeded: false, successHandler: { (finish, res) in
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
        }) { (erroMessage) in
            
        }
    }
    
    func fetchCategory()
    {
        self.startActivityIndicator()
        APIManager.shared.requestForGET(url: "auth/category", isTokenEmbeded: false, successHandler: { (finish, res) in
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
            
        }) { (erroMessage) in
            
        }
    }
    
    func taphandler()
    {
        self.view.subviews.last?.removeFromSuperview()
        self.view.removeGestureRecognizer(tap)
    }
}
