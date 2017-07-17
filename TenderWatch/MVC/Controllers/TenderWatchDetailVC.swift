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
    
    static var id:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getDetail()
        // Do any additional setup after loading the view.
    }

    override func viewDidLayoutSubviews() {
        
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
            Alamofire.request(TENDER_DETAIL+"/\(TenderWatchDetailVC.id!)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(UserManager.shared.user!.authenticationToken!)"]).responseJSON(completionHandler: { (resp) in
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
                        self.lblTenderName.text = (data.value(forKey: "tenderName")! as? String)
                        self.lblCountry.text = (data.value(forKey: "country") as! NSObject).value(forKey: "countryName")! as? String
                            
                        self.lblCategory.text = (data.value(forKey: "category") as! NSObject).value(forKey: "categoryName")! as? String
                        
                        self.lblDay.text = (data.value(forKey: "expiryDate")! as? String)
                        self.txtDesc.text = (data.value(forKey: "description")! as? String)
                        self.lblClienEmail.text = (data.value(forKey: "tenderUploader") as! NSObject).value(forKey: "email")! as? String
                        var url: URL!
                        if (appDelegate.isClient)! {
                            url = URL(string: (data.value(forKey: "tenderPhoto")! as? String)!)
                        } else {
                            url = URL(string: (data.value(forKey: "tenderUploader") as! NSObject).value(forKey: "profilePhoto")! as! String)
                        }
                        self.imgTenderPhoto.sd_setImage(with: url, placeholderImage: UIImage(named: "avtar"), options: SDWebImageOptions.progressiveDownload, completed: { (image, error, memory, url) in
                            SDImageCache.shared().clearMemory()
                        })
                        
                    }
                    self.stopActivityIndicator()
                }            })
        } else {
            MessageManager.showAlert(nil, "No Internet")
        }
    }
}
