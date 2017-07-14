//
//  FavoriteVC.swift
//  TenderWatch
//
//  Created by LaNet on 6/28/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import SDWebImage

class FavoriteVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tblFavorite: UITableView!
    @IBOutlet weak var lblNoFavorite: UILabel!
    
    var favorite = [Favorite]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tblFavorite.delegate = self
        self.tblFavorite.dataSource = self
        
        self.tblFavorite.register(UINib(nibName: "TenderListCell", bundle: nil), forCellReuseIdentifier: "TenderListCell")
                self.getFavorite()
        self.tblFavorite.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- TableView Delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.favorite.isEmpty) {
            return 0
        } else {
            return self.favorite.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  cell = tableView.dequeueReusableCell(withIdentifier: "TenderListCell", for: indexPath) as! TenderListCell
        if !(self.favorite.isEmpty) {
            let tender = self.favorite[indexPath.row]
            cell.lblName.text = (tender.email == "") ? "example@gmail.com" : tender.email
            cell.lblCountry.text = tender.tenderName
            
            cell.imgProfile.sd_setShowActivityIndicatorView(true)
            cell.imgProfile.sd_setIndicatorStyle(.gray)
            //                (tender.tenderPhoto)!
            if (tender.tenderPhoto != nil) {
                cell.imgProfile.sd_setImage(with: URL(string: (tender.tenderPhoto)!), placeholderImage: UIImage(named: "avtar"), options: SDWebImageOptions.progressiveDownload, completed: { (image, error, memory, url) in
                    SDWebImageManager.shared().imageCache?.clearMemory()
                })
            } else {
                cell.imgProfile.image = UIImage(named: "avtar")
            }
            let components = Date().getDifferenceBtnCurrentDate(date: (tender.exp?.substring(to: (tender.exp?.index((tender.exp?.startIndex)!, offsetBy: 10))!))!)
            if (components.day == 1) {
                cell.lblTender.text = "\(components.day!) day"
            } else {
                cell.lblTender.text = "\(components.day!) days"
            }
        }
        
        
        //        if (components.day! < 0) {
        //            deleteTender(indexPath.row)
        //        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    //MARK:- IBActions
    @IBAction func handleBtnMenu(_ sender: Any) {
        appDelegate.drawerController.toggleDrawerSide(.left, animated: true, completion: nil)
    }
    
    func getFavorite() {
        if isNetworkReachable() {
            self.startActivityIndicator()
            Alamofire.request(FAVORITE, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: ["Authorization":"Bearer \(UserManager.shared.user!.authenticationToken!)"]).responseJSON { (resp) in
                if(resp.result.value != nil) {
                    if ((resp.result.value as! NSDictionary).allKeys[0] as! String) == "error" {
                        self.lblNoFavorite.isHidden = false
                    } else {
                        self.lblNoFavorite.isHidden = true
                        print(resp.result.value!)
                        let data = (resp.result.value as! NSObject)
                        self.favorite = Mapper<Favorite>().mapArray(JSONObject: data)!
                        self.tblFavorite.reloadData()
                    }
                    self.stopActivityIndicator()
                }
            }
        } else {
            MessageManager.showAlert(nil, "No Internet")
        }
    }
}
