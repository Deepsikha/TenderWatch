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
        self.tblFavorite.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getFavorite()
        
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
            let fv = self.favorite[indexPath.row]
            cell.lblName.text = (fv.email == "") ? "example@gmail.com" : fv.email
            cell.lblCountry.text = fv.tenderName
            
            cell.imgProfile.sd_setShowActivityIndicatorView(true)
            cell.imgProfile.sd_setIndicatorStyle(.gray)
            //                (tender.tenderPhoto)!
            cell.imgProfile.sd_setImage(with: URL(string: (fv.tenderPhoto)!), placeholderImage: UIImage(named: "avtar"), options: SDWebImageOptions.progressiveDownload, completed: { (image, error, memory, url) in
            })
            
            let components = Date().getDifferenceBtnCurrentDate(date: (fv.exp?.substring(to: (fv.exp?.index((fv.exp?.startIndex)!, offsetBy: 10))!))!)
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
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let dlt = UITableViewRowAction(style: .normal, title: "Remove", handler: { (action, index) in
            print("Remove button tapped")
            let alert = UIAlertController(title: "TenderWatch", message: "Are you sure you want to remove it from favourites??", preferredStyle: UIAlertControllerStyle.alert)
            alert.view.backgroundColor = UIColor.white
            alert.view.layer.cornerRadius = 10.0
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler:{ action in
                tableView.reloadRows(at: [index], with: .fade)
            }))
            alert.addAction(UIAlertAction(title: "Remove", style: .cancel, handler:{ action in
                tableView.reloadRows(at: [index], with: .none)
                self.removeTender(index.row)
                
            }))
            
            self.present(alert, animated: true, completion: nil)
        })
        dlt.backgroundColor = UIColor.red
        
        return [dlt]
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return tableView.isEditing ? UITableViewCellEditingStyle.none : UITableViewCellEditingStyle.delete
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        TenderWatchDetailVC.id = self.favorite[indexPath.row].id
        
        self.navigationController?.pushViewController(TenderWatchDetailVC(), animated: true)
    }
    
    //MARK:- IBActions
    @IBAction func handleBtnMenu(_ sender: Any) {
        appDelegate.drawerController.toggleDrawerSide(.left, animated: true, completion: nil)
    }
    
    func getFavorite() {
        if isNetworkReachable() {
            self.startActivityIndicator()
            Alamofire.request(GET_TENDER, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: ["Authorization":"Bearer \(UserManager.shared.user!.authenticationToken!)"]).responseJSON { (resp) in
                if(resp.result.value != nil) {
                    if (resp.result.value is NSDictionary){
                        self.lblNoFavorite.isHidden = false
                    } else {
                        self.lblNoFavorite.isHidden = true
                        print(resp.result.value!)
                        let data = (resp.result.value as! NSObject)
                        self.favorite = Mapper<Favorite>().mapArray(JSONObject: data)!
                        self.tblFavorite.reloadData()
                    }
                }
                self.stopActivityIndicator()
            }
        } else {
            MessageManager.showAlert(nil, "No Internet")
        }
    }
    
    func removeTender(_ index: Int) {
        
        if isNetworkReachable() {
            self.stopActivityIndicator()
            Alamofire.request(ADD_REMOVE_FAVORITE+favorite[index].id! , method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: ["Authorization":"Bearer \(UserManager.shared.user!.authenticationToken!)"]).responseJSON { (resp) in
                if(resp.response!.statusCode != 202) {
                    MessageManager.showAlert(nil, "can't add to favorite")
                } else {
                    self.favorite.remove(at: index)
                    self.tblFavorite.reloadData()
                    if (self.favorite.isEmpty) {
                        self.lblNoFavorite.isHidden = false
                    }
                    //                        MessageManager.showAlert(nil, "delete Succesfully")
                }
                self.stopActivityIndicator()
            }
        } else {
            MessageManager.showAlert(nil, "No Internet")
        }
    }
}
