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

class TenderWatchVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var user: User!
    @IBOutlet var btnMenu: UIButton!
    @IBOutlet var tblTenderList: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tblTenderList.delegate = self
        self.tblTenderList.dataSource = self
        
        self.tblTenderList.register(UINib(nibName:"TenderListCell",bundle: nil), forCellReuseIdentifier: "TenderListCell")
        
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  cell = tableView.dequeueReusableCell(withIdentifier: "TenderListCell", for: indexPath) as! TenderListCell
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        if !(USER?.role == RollType.client) {
        let fav = UITableViewRowAction(style: .normal, title: "Favourites") { action, index in
            print("Edit button tapped")
        }
        fav.backgroundColor = UIColor.blue
        
        return [fav]
        } else {
            return []
        }
    }
    
    @IBAction func handleBtnMenu(_ sender: Any) {
        appDelegate.drawerController.toggleDrawerSide(.left, animated: true, completion: nil)
    }
    
    func getTender() {
        if isNetworkReachable() {
            //Api Call
        } else {
            MessageManager.showAlert(nil, "No Internet")
        }
    }
    
    func addFavorite() {
        if isNetworkReachable() {
            Alamofire.request("http://192.168.200.22:4040/api/favourite", method: .post, parameters: ["tender" : "Tender_Id"], encoding: JSONEncoding.default, headers: ["Authorization":"Bearer \(UserManager.shared.user!.authenticationToken!)"]).responseJSON { (resp) in
                if(resp.result.value != nil) {
                    if ((resp.result.value as! NSDictionary).allKeys[0] as! String) == "Error" {
                        
                    } else {
                        print(resp.result.value!)
                        let data = (resp.result.value as! NSObject)
//                        self.tender = Mapper<Tender>().mapArray(JSONObject: data)!
                        
                        self.tblTenderList.reloadData()
                    }
                }
            }
        } else {
            MessageManager.showAlert(nil, "No Internet")
        }

    }
    
}
