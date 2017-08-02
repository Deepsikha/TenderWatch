//
//  TenderWatchDetailVC.swift
//  TenderWatch
//
//  Created by devloper65 on 7/17/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage
import ObjectMapper

class TenderWatchDetailVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var imgTenderPhoto: UIImageView!
    @IBOutlet weak var lblTenderName: UILabel!
    @IBOutlet weak var lblCountry: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblDay: UILabel!
    @IBOutlet weak var txtDesc: UITextView!
    @IBOutlet weak var tblTenderContactDetail: UITableView!
    @IBOutlet weak var btnClientDetail: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnInterested: UIButton!
    
    @IBOutlet var vwImage: UIView!
    @IBOutlet weak var imgProfile: UIImageView!
    
    @IBOutlet var vwClientDetail: UIView!
    @IBOutlet weak var imgIsFollow: UIImageView!
    
    @IBOutlet weak var txtVwDescHeight: NSLayoutConstraint!
    @IBOutlet weak var tblTenderContactHeight: NSLayoutConstraint!
    @IBOutlet weak var vwHeight: NSLayoutConstraint!
    
    var transperentView = UIView()
    var cView: UIView!
    var tenderDetail: TenderDetail!
    
    static var id:String!
    var dic: [String: String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btnDelete.layer.cornerRadius = 8
        self.btnInterested.layer.cornerRadius = 8
        
        if appDelegate.isClient! {
            self.btnInterested.setTitle("Amend", for: .normal)
            self.btnInterested.layer.backgroundColor = UIColor.gray.cgColor
        } else {
            self.btnInterested.setTitle("Interested", for: .normal)
            self.btnInterested.layer.backgroundColor = UIColor(red: 145/255, green: 216/255, blue: 79/255, alpha: 1.0).cgColor
            
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.generateSubView(sender:)))
        tap.cancelsTouchesInView = false
        self.imgTenderPhoto.addGestureRecognizer(tap)
        
        self.tblTenderContactDetail.delegate = self
        self.tblTenderContactDetail.dataSource = self
        
        self.tblTenderContactDetail.register(UINib(nibName: "ClienDetailCell", bundle: nil), forCellReuseIdentifier: "ClienDetailCell")
        getDetail()
       
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        
        self.txtVwDescHeight.constant = self.txtDesc.contentSize.height
        self.tblTenderContactHeight.constant = CGFloat(self.dic.count * 30)
        self.vwHeight.constant = self.vwHeight.constant + (self.txtDesc.contentSize.height - self.txtDesc.frame.height) //+ (self.tblTenderContactHeight.constant - 30)
        
        self.vwClientDetail.frame = CGRect(x: self.view.center.x - (self.vwClientDetail.frame.width / 2), y: self.btnClientDetail.bounds.origin.x + 20, width:self.vwClientDetail.frame.width, height: 300)
        self.vwImage.frame = self.view.frame
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Table Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dic.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ClienDetailCell = tableView.dequeueReusableCell(withIdentifier: "ClienDetailCell", for: indexPath) as! ClienDetailCell
        cell.lblKey.text = (dic as NSDictionary).allKeys[indexPath.row] as? String
        cell.lblValue.text = (dic as NSDictionary).value(forKey: cell.lblKey.text!) as? String
        return cell
    }
    
    //MARK:- IBActions
    @IBAction func handleBtnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func handleBtnClientDetail(_ sender: Any) {
        self.generateSubView(sender: sender as! NSObject)
    }
    @IBAction func handleBtnDelete(_ sender: Any) {
        let msg: String!
        if (appDelegate.isClient)! {
            msg = "Tender will be completely removed from TenderWatch?"
        } else {
            msg = "Are you sure you want to remove this Tender completely from your Account?"
        }
        
        let alert = UIAlertController(title: "TenderWatch", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.view.backgroundColor = UIColor.white
        alert.view.layer.cornerRadius = 10.0
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler:{ action in
        }))
        alert.addAction(UIAlertAction(title: "Remove", style: .cancel, handler:{ action in
            if isNetworkReachable() {
                self.stopActivityIndicator()
                Alamofire.request(DELETE_TENDER+self.tenderDetail.id! , method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: ["Authorization":"Bearer \(UserManager.shared.user!.authenticationToken!)"]).responseJSON { (resp) in
                    if(resp.response?.statusCode != nil) {
                        if !(resp.response?.statusCode == 200) {
                            MessageManager.showAlert(nil, "can't Remove tender")
                        } else {
                            TenderWatchVC.id = TenderWatchDetailVC.id
                            self.navigationController?.popViewController(animated: true)
                        }
                        self.stopActivityIndicator()
                    }
                }
            } else {
                MessageManager.showAlert(nil, "No Internet")
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
            }
    
    @IBAction func handleBtnInterested(_ sender: Any) {
        
        if (appDelegate.isClient!) {
            UploadTenderVC.isUpdate = true
            UploadTenderVC.id = TenderWatchDetailVC.id

            self.navigationController?.pushViewController(UploadTenderVC(), animated: true)
            
        } else {
            Alamofire.request(INTERESTED+self.tenderDetail.id!, method: .put, parameters: [:], encoding: JSONEncoding.default, headers: ["Authorization":"Bearer \(UserManager.shared.user!.authenticationToken!)"]).responseJSON(completionHandler: { (resp) in
                if resp.response?.statusCode != nil {
                    if (resp.response?.statusCode == 304) {
                        MessageManager.showAlert(nil, "Already interested ")
                    } else {
                        MessageManager.showAlert(nil, "Tender added to interested")
                        self.btnInterested.isEnabled = false
                        self.btnInterested.backgroundColor = UIColor(red: 145/255, green: 216/255, blue: 79/255, alpha: 0.7)

                        //fire notification
                        //work remaining based on client req.
                    }
                }
            })
            
        }
    }
    
    func getDetail() {
        if isNetworkReachable() {
            self.startActivityIndicator()
            Alamofire.request(TENDER_DETAIL+"\(TenderWatchDetailVC.id!)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(UserManager.shared.user!.authenticationToken!)"]).responseJSON(completionHandler: { (resp) in
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
                        self.tenderDetail = Mapper<TenderDetail>().map(JSONObject: data)
                        if (TenderWatchVC.isAmended) {
                            MessageManager.showAlert(nil, "tender has been amend by the client")
                            TenderWatchVC.isAmended = false
                        }

                        if self.tenderDetail.interested!.contains(USER!._id!) {
                            self.btnInterested.backgroundColor = UIColor(red: 145/255, green: 216/255, blue: 79/255, alpha: 0.7)
                            self.btnInterested.isEnabled = false
                        }
                        self.lblTenderName.text = self.tenderDetail.tenderName!
                        self.lblCountry.text = self.tenderDetail.country!.countryName!
                        
                        self.lblCategory.text = self.tenderDetail.category!.categoryName!
                        
                        
                        if !(self.tenderDetail.email!.isEmpty)  {
                            self.dic["Email:"] = self.tenderDetail.email!
                        }
                        
                        if !(self.tenderDetail.contactNo!.isEmpty)  {
                            self.dic["Mobile No:"] = self.tenderDetail.contactNo!
                        }
                        
                        if !(self.tenderDetail.landlineNo!.isEmpty)  {
                            self.dic["LandLine No:"] = self.tenderDetail.landlineNo!
                        }
                        
                        if !(self.tenderDetail.address!.isEmpty)  {
                            self.dic["Address:"] = self.tenderDetail.address!
                        }
                        
                        let date = data.value(forKey: "expiryDate")! as? String
                        let components = Date().getDifferenceBtnCurrentDate(date: (date?.substring(to: (date!.index((date!.startIndex), offsetBy: 10))))!)
                        
                        if (components.day == 1) {
                            self.lblDay.text = "\(components.day!) day"
                        } else {
                            self.lblDay.text = "\(components.day!) days"
                        }
                        
                        self.txtDesc.text = self.tenderDetail.desc!
//                        self.lblClienEmail.text = self.tenderDetail.tenderUploader!.email!
                        
//                        if (appDelegate.isClient!) {
                            self.imgTenderPhoto.sd_setImage(with: URL(string: self.tenderDetail.tenderPhoto!), placeholderImage: UIImage(named: "avtar"), options: SDWebImageOptions.progressiveDownload, completed: { (image, error, memory, url) in
                                if image != nil {
                                    self.imgProfile.image = image!
                                } else {
                                    self.imgProfile.image = UIImage(named: "avtar")
                                }
                                
                            })
//                        } else {
//                            self.imgTenderPhoto.sd_setImage(with: URL(string: self.tenderDetail.tenderUploader!.profilePhoto!), placeholderImage: UIImage(named: "avtar"), options: SDWebImageOptions.progressiveDownload, completed: { (image, error, memory, url) in
//                                if image != nil {
//                                    self.imgProfile.image = image!
//                                } else {
//                                    self.imgProfile.image = UIImage(named: "avtar")
//                                }
//                            })
//                        }
                    }
                    self.tblTenderContactDetail.reloadData()
                    self.stopActivityIndicator()
                }
            })
        } else {
            MessageManager.showAlert(nil, "No Internet")
        }
    }
    
    func generateSubView(sender: NSObject) {
//        self.transperentView = UIView(frame: UIScreen.main.bounds)
//        self.transperentView.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.1)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapHandler(sender:)))
        tap.cancelsTouchesInView = false
        
        if sender == self.btnClientDetail {
            if !self.view.subviews.contains(self.vwClientDetail) {
                self.view.addSubview(self.vwClientDetail)
            }
            self.vwClientDetail.addGestureRecognizer(tap)
        } else {
            if !self.view.subviews.contains(self.vwImage) {
                self.view.addSubview(self.vwImage)
            }
            self.vwImage.addGestureRecognizer(tap)
        }
        
//        view.addSubview(childView)
//        self.cView = childView
        
        
    }
    
    func tapHandler(sender: NSObject) {
        if self.view.subviews.contains(self.vwClientDetail) {
            self.vwClientDetail.removeFromSuperview()
        }
        if self.view.subviews.contains(self.vwImage) {
            self.vwImage.removeFromSuperview()
        }
    }
    
}
