//
//  NotificationVC.swift
//  TenderWatch
//
//  Created by LaNet on 6/28/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import SDWebImage

class NotificationVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tblNotifications: UITableView!
    @IBOutlet weak var lblNoNotifications: UILabel!
    @IBOutlet weak var btnEdit: UIButton!
    
    @IBOutlet var dwView: UIView!
    @IBOutlet weak var btnDelete: UIButton!
    var notification: [Notification] = []
    var delete: [String] = []
    var count : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblNotifications.delegate = self
        self.tblNotifications.dataSource = self
        
        self.tblNotifications.register(UINib(nibName: "NotificationCell", bundle: nil), forCellReuseIdentifier: "NotificationCell")
        self.tblNotifications.tableFooterView = UIView()
        self.tblNotifications.allowsSelectionDuringEditing = true
        
        self.tblNotifications.setEditing(false, animated: true)

        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        self.dwView.frame = CGRect(x: 0, y: self.view.frame.height - self.dwView.frame.height, width: self.dwView.frame.width, height: self.dwView.frame.height)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getNotification()
        self.navigationController?.isNavigationBarHidden = true
        self.tblNotifications.reloadData()
        if self.notification.isEmpty {
            self.lblNoNotifications.isHidden = false
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.tblNotifications.setEditing(false, animated: true)
        self.btnEdit.setTitle("Edit", for: .normal)
        if (self.view.subviews.contains(self.dwView)) {
            self.dwView.removeFromSuperview()
        }
    }
    
    //MARK:- Table Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.notification.isEmpty) {
            return 0
        } else {
            return self.notification.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        let noti = self.notification[indexPath.row]
        cell.lblContent.text = noti.message
        cell.imgSender.sd_setImage(with: URL(string: noti.user!.profilePhoto!), placeholderImage: nil, options: SDWebImageOptions.progressiveDownload) { (image, error, memory, url) in
        }
        cell.imgSender.backgroundColor = UIColor.gray
        
        //        if (components.day! < 0) {
        //            deleteTender(indexPath.row)
        //        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let dlt = UITableViewRowAction(style: .normal, title: "Remove", handler: { (action, index) in
            print("Remove button tapped")
            let alert = UIAlertController(title: "TenderWatch", message: "Are you sure you want to remove it from Notification??", preferredStyle: UIAlertControllerStyle.alert)
            alert.view.backgroundColor = UIColor.white
            alert.view.layer.cornerRadius = 10.0
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler:{ action in
                tableView.reloadRows(at: [index], with: .fade)
            }))
            alert.addAction(UIAlertAction(title: "Remove", style: .cancel, handler:{ action in
                tableView.reloadRows(at: [index], with: .none)
                self.delete.append(self.notification[index.row].id!)
                self.removeNotification(index.row, self.delete)
                
            }))
            
            self.present(alert, animated: true, completion: nil)
        })
        dlt.backgroundColor = UIColor.red
        
        return [dlt]
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return tableView.isEditing ? UITableViewCellEditingStyle.none : UITableViewCellEditingStyle.delete
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        TenderWatchDetailVC.id = self.notification[indexPath.row]
//        
//        self.navigationController?.pushViewController(TenderWatchDetailVC(), animated: true)
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        count = count + 1
        if ((tblNotifications.indexPathsForSelectedRows?.count)! > 0) {
            self.btnDelete.isEnabled = true
        } else {
            self.btnDelete.isEnabled = false
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        count = count - 1
        if ( count !=  0) {
                self.btnDelete.isEnabled = true
        } else {
            self.btnDelete.isEnabled = false
        }
    }
    
    //MARK:- IBAction
    @IBAction func handleBtnMenu(_ sender: Any) {
        appDelegate.drawerController.toggleDrawerSide(.left, animated: true, completion: nil)
    }
    
    @IBAction func handleBtnEdit(_ sender: Any) {
        if (self.tblNotifications.isEditing) {
            self.tblNotifications.setEditing(false, animated: true)
            if (self.view.subviews.contains(self.dwView)) {
                self.dwView.removeFromSuperview()
            }
            self.btnEdit.setTitle("Edit", for: .normal)
        } else {
            self.btnEdit.setTitle("Cancel", for: .normal)
            self.tblNotifications.setEditing(true, animated: true)
            self.view.addSubview(self.dwView)
        }
    }
    
    @IBAction func handleBtnDelete(_ sender: Any) {
        if (self.notification.count == 0) {
            self.lblNoNotifications.isHidden = false
            self.btnEdit.isEnabled = false
        }
        
        if let indexPaths = self.tblNotifications.indexPathsForSelectedRows  {
            let sortedArray = indexPaths.sorted {$0.row < $1.row}
            for i in (0...sortedArray.count-1).reversed() {
                self.delete.append(self.notification[sortedArray[i].row].id!)
                self.notification.remove(at: sortedArray[i].row)
            }
            self.tblNotifications.deleteRows(at: sortedArray, with: .automatic)
            self.removeNotification(-1, self.delete)
//            self.tbl
        }
    }
    
    //MARK:- Custom Methods
    func getNotification() {
        if isNetworkReachable() {
            self.startActivityIndicator()
            Alamofire.request(READ_NOTIFY, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: ["Authorization":"Bearer \(UserManager.shared.user!.authenticationToken!)"]).responseJSON(completionHandler: { (resp) in
                if(resp.result.value != nil) {
                    if resp.result.value is NSDictionary {
                        //                        MessageManager.showAlert(nil,"\(String(describing: (resp.result.value as AnyObject).value(forKey: "message"))))")
                        self.lblNoNotifications.isHidden = false
                    } else {
                        self.lblNoNotifications.isHidden = true
                        let data = (resp.result.value as! NSObject)
                        self.notification = Mapper<Notification>().mapArray(JSONObject: data)!
                        if (self.notification.isEmpty) {
                            self.lblNoNotifications.isHidden = false
                            self.btnEdit.isEnabled = false
                        }
                        self.tblNotifications.reloadData()
                        self.stopActivityIndicator()
                    }
                }
                print(resp.result)
                self.stopActivityIndicator()
            })
        } else {
            MessageManager.showAlert(nil, "No Internet")
            self.stopActivityIndicator()
        }
    }
    
    func removeNotification(_ index: Int,_ string: [String]) {
        
        if isNetworkReachable() {
            self.stopActivityIndicator()
            Alamofire.request(NOTIFICATION , method: .delete, parameters: ["notificationns":string], encoding: JSONEncoding.default, headers: ["Authorization":"Bearer \(UserManager.shared.user!.authenticationToken!)"]).responseJSON { (resp) in
                if(resp.response?.statusCode != nil) {
                    if !(resp.response?.statusCode == 200) {
                        MessageManager.showAlert(nil, "can't Remove Notification")
                    } else {
                        if (index != -1) {
                            self.notification.remove(at: index)
                        }
                        self.tblNotifications.reloadData()
                        if (self.notification.isEmpty) {
                            self.lblNoNotifications.isHidden = false
                        }
                        //                        MessageManager.showAlert(nil, "Remove Succesfully")
                    }
                    self.stopActivityIndicator()
                }
                self.delete.removeAll()
                self.count = 0
                self.btnDelete.isEnabled = false
            }
        } else {
            MessageManager.showAlert(nil, "No Internet")
        }
    }
}
