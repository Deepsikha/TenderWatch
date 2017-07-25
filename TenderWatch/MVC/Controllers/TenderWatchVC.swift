//
//  TenderWatchVC.swift
//  TenderWatch
//
//  Created by Devloper30 on 20/06/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit
import ObjectMapper
import Alamofire
import SDWebImage

class TenderWatchVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet var btnMenu: UIButton!
    @IBOutlet var tblTenderList: UITableView!
    @IBOutlet weak var lblNoTender: UILabel!
    
    var tender = [Tender]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tblTenderList.delegate = self
        self.tblTenderList.dataSource = self
        
        self.tblTenderList.register(UINib(nibName:"TenderListCell",bundle: nil), forCellReuseIdentifier: "TenderListCell")
        self.tblTenderList.tableFooterView = UIView()
//        
//        self.tblTenderList.estimatedRowHeight = 85
//        self.tblTenderList.rowHeight = UITableViewAutomaticDimension
        
        self.getTender()
        // Do any additional setup after loading the view.
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
        if (self.tender.isEmpty) {
            return 0
        } else {
            return self.tender.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  cell = tableView.dequeueReusableCell(withIdentifier: "TenderListCell", for: indexPath) as! TenderListCell
        
        let tender = self.tender[indexPath.row]
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
        //Day remainning 
        //pass string in "yyyy-MM-dd" format
        let components = Date().getDifferenceBtnCurrentDate(date: (tender.exp?.substring(to: (tender.exp?.index((tender.exp?.startIndex)!, offsetBy: 10))!))!)
        if (components.day == 1) {
            cell.lblTender.text = "\(components.day!) day"
        } else {
            cell.lblTender.text = "\(components.day!) days"
        }
        
        
//        if (components.day! < 0) {
//            deleteTender(indexPath.row)
//        }
        
        return cell
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        TenderWatchDetailVC.id = self.tender[indexPath.row].id
        
        self.navigationController?.pushViewController(TenderWatchDetailVC(), animated: true)
    }
    
//    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let fav = UITableViewRowAction(style: .normal, title: "Favorites") { action, index in
            print("Edit button tapped")
            self.addFavorite(index)
            tableView.reloadRows(at: [index], with: .none)
        }
        let dlt = UITableViewRowAction(style: .normal, title: "Delete", handler: { (action, index) in
            print("Delete button tapped")
            let alert = UIAlertController(title: "TenderWatch", message: "Confirm Deletion?", preferredStyle: UIAlertControllerStyle.alert)
            alert.view.backgroundColor = UIColor.white
            alert.view.layer.cornerRadius = 10.0
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler:{ action in
                tableView.reloadRows(at: [index], with: .fade)
            }))
            alert.addAction(UIAlertAction(title: "Delete", style: .cancel, handler:{ action in
                tableView.reloadRows(at: [index], with: .none)
                self.deleteTender(index.row)
                
            }))
            
            self.present(alert, animated: true, completion: nil)
        })
        
        let update = UITableViewRowAction(style: .normal, title: "Update") { action, index in
            print("Update button tapped")
//            self.navigationController?.pushViewController(UploadTenderVC(), animated: true)
        }
        dlt.backgroundColor = UIColor.red
        fav.backgroundColor = UIColor.blue
        update.backgroundColor = UIColor.gray

        if !(USER?.role?.rawValue == RollType.client.rawValue) {
            if ((self.tender[editActionsForRowAt.row].favorite?.count)! > 0) {
                if (self.tender[editActionsForRowAt.row].favorite?.contains((USER?._id)!))!{
                    return [dlt]
                } else {
                    return [dlt,fav]
                }
            } else {
                return [dlt,fav]
            }
        } else {
            return [dlt, update]
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return tableView.isEditing ? UITableViewCellEditingStyle.none : UITableViewCellEditingStyle.delete
    }
    
    //MARK:- IBActions
    @IBAction func handleBtnMenu(_ sender: Any) {
        appDelegate.drawerController.toggleDrawerSide(.left, animated: true, completion: nil)
    }
    
    //MARK:- Custom Method
    func getTender() {
        if isNetworkReachable() {
            self.startActivityIndicator()
            Alamofire.request(GET_TENDER, method: .post, parameters: ["role" : appDelegate.isClient! ? "client" : "contractor"], encoding: JSONEncoding.default, headers: ["Authorization":"Bearer \(UserManager.shared.user!.authenticationToken!)"]).responseJSON { (resp) in
                if(resp.result.value != nil) {
                    if resp.result.value is NSDictionary {
//                        MessageManager.showAlert(nil,"\(String(describing: (resp.result.value as AnyObject).value(forKey: "message"))))")
                        self.lblNoTender.isHidden = false
                    } else {
                        self.lblNoTender.isHidden = true
                        let data = (resp.result.value as! NSObject)
                        self.tender = Mapper<Tender>().mapArray(JSONObject: data)!
                        
                        self.tblTenderList.reloadData()
                        self.stopActivityIndicator()
                    }
                }
                print(resp.result)
                self.stopActivityIndicator()
            }
        } else {
            MessageManager.showAlert(nil, "No Internet")
            self.stopActivityIndicator()
        }
    }
    
    func addFavorite(_ index: IndexPath) {
        if isNetworkReachable() {
            self.startActivityIndicator()
            Alamofire.request(ADD_REMOVE_FAVORITE+tender[index.row].id!, method: .put, parameters: ["tender" : "Tender_Id"], encoding: JSONEncoding.default, headers: ["Authorization":"Bearer \(UserManager.shared.user!.authenticationToken!)"]).responseJSON { (resp) in
                if(resp.result.value != nil) {
                    if ((resp.result.value as! NSDictionary).allKeys.contains(where: { (a) -> Bool in
                        if (a as! String) == "error" {
                            return true
                        } else {
                            return false
                        }
                    })) {
                        MessageManager.showAlert(nil, "can't add to favorite")
                    } else {
                        MessageManager.showAlert(nil, "Added Succesfully")
                        self.tender[index.row].favorite = (resp.result.value as! NSObject).value(forKey: "favorite") as? [String]
                        self.tblTenderList.reloadRows(at: [index], with: .none)
                    }
                    self.stopActivityIndicator()
                }
            }
        } else {
            MessageManager.showAlert(nil, "No Internet")
            self.stopActivityIndicator()
        }
    }
    
    func deleteTender(_ index: Int) {
       
        if isNetworkReachable() {
            self.stopActivityIndicator()
            Alamofire.request(DELETE_TENDER+tender[index].id! , method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: ["Authorization":"Bearer \(UserManager.shared.user!.authenticationToken!)"]).responseJSON { (resp) in
                if(resp.response?.statusCode != nil) {
                    if !(resp.response?.statusCode == 200) {
                        MessageManager.showAlert(nil, "can't Delete tender")
                    } else {
                        self.tender.remove(at: index)
                        self.tblTenderList.reloadData()
                        if (self.tender.isEmpty) {
                            self.lblNoTender.isHidden = false
                        }
//                        MessageManager.showAlert(nil, "delete Succesfully")
                    }
                    self.stopActivityIndicator()
                }
            }
        } else {
            MessageManager.showAlert(nil, "No Internet")
        }
    }
}
