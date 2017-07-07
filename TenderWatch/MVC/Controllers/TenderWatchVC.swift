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
    
    //MARK:- TableView Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tender.count
        //                return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  cell = tableView.dequeueReusableCell(withIdentifier: "TenderListCell", for: indexPath) as! TenderListCell
        
        let tender = self.tender[indexPath.row]
        cell.lblName.text = (tender.email == "") ? "example@gmail.com" : tender.email
        cell.lblCountry.text = tender.country
        cell.lblTender.text = tender.exp
        
        cell.imgProfile.sd_setShowActivityIndicatorView(true)
        cell.imgProfile.sd_setIndicatorStyle(.gray)
        //        (tender.tenderPhoto)!
        cell.imgProfile.sd_setImage(with: URL(string: "https://camo.mybb.com/e01de90be6012adc1b1701dba899491a9348ae79/687474703a2f2f7777772e6a71756572797363726970742e6e65742f696d616765732f53696d706c6573742d526573706f6e736976652d6a51756572792d496d6167652d4c69676874626f782d506c7567696e2d73696d706c652d6c69676874626f782e6a7067"), placeholderImage: UIImage(named: "avtar"), options: SDWebImageOptions.progressiveDownload, completed: { (image, error, memory, url) in
        })
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        if !(USER?.role?.rawValue == RollType.client.rawValue) {
            let fav = UITableViewRowAction(style: .normal, title: "Favourites") { action, index in
                print("Edit button tapped")
                self.addFavorite()
            }
            fav.backgroundColor = UIColor.blue
            return [fav]
        } else {
            let dlt = UITableViewRowAction(style: .normal, title: "Delete", handler: { (action, index) in
                print("Delete button tapped")
                self.deleteTender(index.row)
            })
            dlt.backgroundColor = UIColor.red
            return [dlt]
        }
    }
    
    //MARK:- IBActions
    @IBAction func handleBtnMenu(_ sender: Any) {
        appDelegate.drawerController.toggleDrawerSide(.left, animated: true, completion: nil)
    }
    
    //MARK:- Custom Method
    func getTender() {
        if isNetworkReachable() {
            self.startActivityIndicator()
            Alamofire.request(GET_TENDER, method: .post, parameters: ["role" : "\(USER?.role?.rawValue as! String)"], encoding: JSONEncoding.default, headers: ["Authorization":"Bearer \(UserManager.shared.user!.authenticationToken!)"]).responseJSON { (resp) in
                if(resp.result.value != nil) {
                    print(resp.result.value!)
                    let data = (resp.result.value as! NSObject)
                    self.tender = Mapper<Tender>().mapArray(JSONObject: data)!
                    self.tblTenderList.reloadData()
                    self.stopActivityIndicator()
                }
                print(resp.result)
                self.stopActivityIndicator()
            }
        } else {
            MessageManager.showAlert(nil, "No Internet")
            self.stopActivityIndicator()
        }
    }
    
    func addFavorite() {
        if isNetworkReachable() {
            self.startActivityIndicator()
            Alamofire.request("\(BASE_URL)favourite", method: .post, parameters: ["tender" : "Tender_Id"], encoding: JSONEncoding.default, headers: ["Authorization":"Bearer \(UserManager.shared.user!.authenticationToken!)"]).responseJSON { (resp) in
                if(resp.result.value != nil) {
                    if ((resp.result.value as! NSDictionary).allKeys[0] as! String) == "error" {
                        MessageManager.showAlert(nil, "can't add to favorite")
                    } else {
                        MessageManager.showAlert(nil, "Added Succesfully")
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
        self.tender.remove(at: index)
        self.tblTenderList.reloadData()
    }
}
