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

class TenderWatchDetailVC: UIViewController {

    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var imgTenderPhoto: UIImageView!
    @IBOutlet weak var lblTenderName: UILabel!
    @IBOutlet weak var lblCountry: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblDay: UILabel!
    @IBOutlet weak var txtDesc: UITextView!
    @IBOutlet weak var lblClienEmail: UILabel!
    @IBOutlet weak var btnClientDetail: UIButton!
    
    @IBOutlet var vwMain: UIView!
    
    var transperentView = UIView()
    var cView: UIView!
    var tenderDetail: TenderDetail!
    
    static var id:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getDetail()
        // Do any additional setup after loading the view.
    }

    override func viewDidLayoutSubviews() {
        self.imgTenderPhoto.layer.cornerRadius = self.imgTenderPhoto.frame.height / 2
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

     @IBAction func handleBtnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
     }
    
    
    @IBAction func handleBtnClientDetail(_ sender: Any) {
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
                        self.lblTenderName.text = self.tenderDetail.tenderName!
                        self.lblCountry.text = self.tenderDetail.country!.countryName!
                            
                        self.lblCategory.text = self.tenderDetail.category!.categoryName!
                        
                        let date = data.value(forKey: "expiryDate")! as? String
                        let components = Date().getDifferenceBtnCurrentDate(date: (date?.substring(to: (date!.index((date!.startIndex), offsetBy: 10))))!)
                        
                        if (components.day == 1) {
                            self.lblDay.text = "\(components.day!) day"
                        } else {
                            self.lblDay.text = "\(components.day!) days"
                        }
                        
                        self.txtDesc.text = self.tenderDetail.desc!
                        self.lblClienEmail.text = self.tenderDetail.tenderUploader!.email!
                        
                        if (appDelegate.isClient!) {
                           
                            self.imgTenderPhoto.sd_setImage(with: URL(string: self.tenderDetail.tenderPhoto!), placeholderImage: UIImage(named: "avtar"), options: SDWebImageOptions.progressiveDownload, completed: { (image, error, memory, url) in
                            })
                        } else {
                            self.imgTenderPhoto.sd_setImage(with: URL(string: self.tenderDetail.tenderUploader!.profilePhoto!), placeholderImage: UIImage(named: "avtar"), options: SDWebImageOptions.progressiveDownload, completed: { (image, error, memory, url) in
                            })
                        }
                    }
                    self.stopActivityIndicator()
                }
            })
        } else {
            MessageManager.showAlert(nil, "No Internet")
        }
    }
    
    func generateSubView(childView: UIView) {
        self.transperentView = UIView(frame: UIScreen.main.bounds)
        self.transperentView.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.1)
        if !self.view.subviews.contains(self.transperentView) {
            self.view.addSubview(self.transperentView)
        }
        view.addSubview(childView)
        self.cView = childView
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapHandler))
        tap.cancelsTouchesInView = false
        self.transperentView.addGestureRecognizer(tap)
    }
    
    func tapHandler() {
        if self.view.subviews.contains(self.cView) {
            self.cView.removeFromSuperview()
        }
        if self.view.subviews.contains(transperentView) {
            transperentView.removeFromSuperview()
//            setTableDelegate(tblAddItems)
        }
    }
}
