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
    static var id: String = ""
    static var isAmended: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tblTenderList.delegate = self
        self.tblTenderList.dataSource = self
        
        self.tblTenderList.register(UINib(nibName:"TenderListCell",bundle: nil), forCellReuseIdentifier: "TenderListCell")
        self.tblTenderList.tableFooterView = UIView()
        //
        //        self.tblTenderList.estimatedRowHeight = 85
        //        self.tblTenderList.rowHeight = UITableViewAutomaticDimension
        NotificationCenter.default.addObserver(self, selector: #selector(countmsg(notification:)), name: NSNotification.Name(rawValue : "interested"), object: nil)
        
        self.getTender()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        if !(TenderWatchVC.id.isEmpty) {
            let a = self.tender.index(where: { (a) -> Bool in
                a.id == TenderWatchVC.id
            })
            self.tender.remove(at: a!)
            MessageManager.showAlert(nil, "Delete Succesfully")
            if (self.tender.isEmpty) {
                self.lblNoTender.isHidden = false
            }
            TenderWatchVC.id = ""
        }
        self.tblTenderList.reloadData()
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
        cell.lblName.text = appDelegate.isClient! ? USER?.email : ((self.tender[indexPath.row].tenderUploader!.email!).isEmpty) ? "nthg" : self.tender[indexPath.row].tenderUploader!.email!
        cell.lblCountry.text = tender.tenderName
        
        cell.imgProfile.sd_setShowActivityIndicatorView(true)
        cell.imgProfile.sd_setIndicatorStyle(.gray)
        //                (tender.tenderPhoto)!
        cell.imgProfile.sd_setImage(with: URL(string: (tender.tenderPhoto)!), placeholderImage: UIImage(named: "avtar"), options: SDWebImageOptions.progressiveDownload, completed: { (image, error, memory, url) in
        })
        
        //Day remainning
        //pass string in "yyyy-MM-dd" format
        let components = Date().getDifferenceBtnCurrentDate(date: (tender.exp?.substring(to: (tender.exp?.index((tender.exp?.startIndex)!, offsetBy: 10))!))!)
        
        cell.lblTender.text = (components.day == 1) ? "\(components.day!) day" : "\(components.day!) days"
        if (!(appDelegate.isClient)!) {
            if !((tender.readby!.contains((USER!._id)!))) {
                cell.lblName.font = UIFont.boldSystemFont(ofSize: cell.lblName.font.pointSize)
                cell.lblTender.font = UIFont.boldSystemFont(ofSize: cell.lblTender.font.pointSize)
                cell.lblCountry.font = UIFont.boldSystemFont(ofSize: cell.lblCountry.font.pointSize)
                
                cell.name.font = UIFont.boldSystemFont(ofSize: cell.name.font.pointSize)
                cell.title.font = UIFont.boldSystemFont(ofSize: cell.title.font.pointSize)
                cell.exp_day.font = UIFont.boldSystemFont(ofSize: cell.exp_day.font.pointSize)
            } else {
                cell.lblName.font = UIFont.systemFont(ofSize: cell.lblName.font.pointSize)
                cell.lblCountry.font = UIFont.systemFont(ofSize: cell.lblCountry.font.pointSize)
                cell.lblTender.font = UIFont.systemFont(ofSize: cell.lblTender.font.pointSize)
                
                cell.name.font = UIFont.systemFont(ofSize: cell.name.font.pointSize)
                cell.title.font = UIFont.systemFont(ofSize: cell.title.font.pointSize)
                cell.exp_day.font = UIFont.systemFont(ofSize: cell.exp_day.font.pointSize)
            }
        }
        //        if (components.day! < 0) {
        //            deleteTender(indexPath.row)
        //        }
        if !(appDelegate.isClient!) {
            if (tender.amendRead != nil) {
                if !(tender.amendRead?.contains((USER!._id)!))! {
                    cell.imgProfile.layer.borderWidth = 2
                    cell.imgProfile.layer.borderColor = UIColor.red.cgColor
                } else {
                    cell.imgProfile.layer.borderWidth = 0
                    cell.imgProfile.layer.borderColor = UIColor.clear.cgColor
                }
            }
        } else {
            cell.imgProfile.layer.borderWidth = 0
            cell.imgProfile.layer.borderColor = UIColor.clear.cgColor
        }
        
        if !(appDelegate.isClient!) {
            if !(tender.interested!.isEmpty) {
                if tender.interested!.contains(USER!._id!) {
                    cell.imgProfile.layer.borderWidth = 2
                    cell.imgProfile.layer.borderColor = UIColor.green.cgColor
                } else {
                    cell.imgProfile.layer.borderWidth = 0
                    cell.imgProfile.layer.borderColor = UIColor.clear.cgColor
                }
            } else {
                cell.imgProfile.layer.borderWidth = 0
                cell.imgProfile.layer.borderColor = UIColor.clear.cgColor
            }
        } else {
            cell.imgProfile.layer.borderWidth = 0
            cell.imgProfile.layer.borderColor = UIColor.clear.cgColor
        }
        return cell
    }
    
    //    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //        return UITableViewAutomaticDimension
    //    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        TenderWatchDetailVC.id = self.tender[indexPath.row].id
        tableView.reloadRows(at: [indexPath], with: .none)
        if !(appDelegate.isClient!) {
            self.tender[indexPath.row].readby?.append((USER?._id)!)
            if (self.tender[indexPath.row].amendRead != nil) {
                if !(tender[indexPath.row].amendRead?.contains((USER!._id)!))! {
                    self.tender[indexPath.row].amendRead?.append(USER!._id!)
                    TenderWatchVC.isAmended = true
                }
            }
        }
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
        let dlt = UITableViewRowAction(style: .normal, title: "Remove", handler: { (action, index) in
            print("Remove button tapped")
            let msg: String!
            if (appDelegate.isClient!) {
                msg = "Tender will be completely removed from TenderWatch?"
            } else {
                msg = "Are you sure you want to remove this Tender completely from your Account?"
            }
            let alert = UIAlertController(title: "TenderWatch", message: msg, preferredStyle: UIAlertControllerStyle.alert)
            alert.view.backgroundColor = UIColor.white
            alert.view.layer.cornerRadius = 10.0
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler:{ action in
                tableView.reloadRows(at: [index], with: .fade)
            }))
            alert.addAction(UIAlertAction(title: "Remove", style: .cancel, handler:{ action in
                tableView.reloadRows(at: [index], with: .none)
                self.deleteTender(index.row)
                
            }))
            
            self.present(alert, animated: true, completion: nil)
        })
        
        let update = UITableViewRowAction(style: .normal, title: "Amend") { action, index in
            print("Update button tapped")
            UploadTenderVC.isUpdate = true
            UploadTenderVC.id = self.tender[index.row].id
            tableView.reloadRows(at: [index], with: .none)
            self.navigationController?.pushViewController(UploadTenderVC(), animated: true)
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
                        MessageManager.showAlert(nil, "can't Remove tender")
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

    func countmsg(notification: NSNotification) {
        if !(notification.userInfo!["id"]! as! String).isEmpty {
            let tender = self.tender.filter{$0.id == (notification.userInfo!["id"]! as! String)}[0]
            tender.interested?.append((USER?._id!)!)
        }
    }
}
