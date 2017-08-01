//
//  NotificationVC.swift
//  TenderWatch
//
//  Created by LaNet on 6/28/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit

class NotificationVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tblNotifications: UITableView!
    @IBOutlet weak var lblNoNotifications: UILabel!
    
    var notification: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblNotifications.delegate = self
        self.tblNotifications.dataSource = self
        
        self.tblNotifications.register(UINib(nibName: "SubscriptionCell", bundle: nil), forCellReuseIdentifier: "SubscriptionCell")
        self.tblNotifications.tableFooterView = UIView()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.notification.append("mike")
        self.tblNotifications.reloadData()
        self.lblNoNotifications.isHidden = false
        
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
        let  cell = tableView.dequeueReusableCell(withIdentifier: "SubscriptionCell", for: indexPath) as! SubscriptionCell
        
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
//                self.removeTender(index.row)
                
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
    //MARK:- IBAction
    @IBAction func handleBtnMenu(_ sender: Any) {
        appDelegate.drawerController.toggleDrawerSide(.left, animated: true, completion: nil)
    }
}
