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
    
    @IBOutlet var btnMenu: UIButton!
    @IBOutlet var tblTenderList: UITableView!
    
    var tender = [Tender]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tblTenderList.delegate = self
        self.tblTenderList.dataSource = self
        
        self.tblTenderList.register(UINib(nibName:"TenderListCell",bundle: nil), forCellReuseIdentifier: "TenderListCell")
        
        self.tblTenderList.tableFooterView = UIView()
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
        return self.tender.count
        //        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  cell = tableView.dequeueReusableCell(withIdentifier: "TenderListCell", for: indexPath) as! TenderListCell
        
        //        let tender = self.tender[indexPath.row]
        //        cell.lblName.text = tender.email
        //        cell.lblCountry.text = tender.country
        //        cell.lblTender.text = tender.tenderName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        if !(USER?.role == RollType.client) {
            let fav = UITableViewRowAction(style: .normal, title: "Favourites") { action, index in
                print("Edit button tapped")
                self.addFavorite()
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
            //end point192.168.200.22:4040/api/tender/getTenders
            Alamofire.request("\(BASE_URL)tender/getTenders", method: .post, parameters: ["role" : "client"], encoding: JSONEncoding.default, headers: ["Authorization":"Bearer \(UserManager.shared.user!.authenticationToken!)"]).responseJSON { (resp) in
                if(resp.result.value != nil) {
                    print(resp.result.value!)
                    let data = (resp.result.value as! NSObject)
                    self.tender = Mapper<Tender>().mapArray(JSONObject: data)!
                    self.tblTenderList.reloadData()
                }
                print(resp.result)
            }
        } else {
            MessageManager.showAlert(nil, "No Internet")
        }
    }
    
    func addFavorite() {
        if isNetworkReachable() {
            Alamofire.request("\(BASE_URL)favourite", method: .post, parameters: ["tender" : "Tender_Id"], encoding: JSONEncoding.default, headers: ["Authorization":"Bearer \(UserManager.shared.user!.authenticationToken!)"]).responseJSON { (resp) in
                if(resp.result.value != nil) {
                    if ((resp.result.value as! NSDictionary).allKeys[0] as! String) == "error" {
                        MessageManager.showAlert(nil, "can't add to favorite")
                    } else {
                        MessageManager.showAlert(nil, "Added Succesfully")
                    }
                }
            }
        } else {
            MessageManager.showAlert(nil, "No Internet")
        }
    }
}
