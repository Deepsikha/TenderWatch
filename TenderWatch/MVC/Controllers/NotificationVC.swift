//
//  NotificationVC.swift
//  TenderWatch
//
//  Created by LaNet on 6/28/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit

class NotificationVC: UIViewController {

    @IBOutlet weak var tblNotifications: UITableView!
    @IBOutlet weak var lblNoNotifications: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblNoNotifications.isHidden = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }

    //MARK:- IBAction
    @IBAction func handleBtnMenu(_ sender: Any) {
        appDelegate.drawerController.toggleDrawerSide(.left, animated: true, completion: nil)
    }
}
