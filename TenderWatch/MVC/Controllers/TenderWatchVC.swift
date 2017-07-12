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
        //                        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  cell = tableView.dequeueReusableCell(withIdentifier: "TenderListCell", for: indexPath) as! TenderListCell
        
        let tender = self.tender[indexPath.row]
        cell.lblName.text = (tender.email == "") ? "example@gmail.com" : tender.email
        cell.lblCountry.text = tender.tenderName
        
        cell.imgProfile.sd_setShowActivityIndicatorView(true)
        cell.imgProfile.sd_setIndicatorStyle(.gray)
        //        (tender.tenderPhoto)!
        if (tender.tenderPhoto != nil) {
            cell.imgProfile.sd_setImage(with: URL(string: (tender.tenderPhoto)!), placeholderImage: UIImage(named: "avtar"), options: SDWebImageOptions.progressiveDownload, completed: { (image, error, memory, url) in
            })
        } else {
            cell.imgProfile.image = UIImage(named: "avtar")
        }
        //Day remainning
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let startDate:NSDate = dateFormatter.date(from: (tender.exp?.substring(to: (tender.exp?.index((tender.exp?.startIndex)!, offsetBy: 10))!))!)! as NSDate
        
        let components = NSCalendar.current.dateComponents([.month, .day, .hour, .minute, .second], from: (NSDate() as Date), to: startDate as Date)

        
        cell.lblTender.text = String(describing: components.day!)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let fav = UITableViewRowAction(style: .normal, title: "Favourites") { action, index in
            print("Edit button tapped")
            self.addFavorite()
        }
        let dlt = UITableViewRowAction(style: .normal, title: "Delete", handler: { (action, index) in
            print("Delete button tapped")
            self.deleteTender(index.row)
        })
        dlt.backgroundColor = UIColor.red
        fav.backgroundColor = UIColor.blue

        if !(USER?.role?.rawValue == RollType.client.rawValue) {
            
            return [dlt,fav]
        } else {
            
            return [dlt]
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
            Alamofire.request(GET_TENDER, method: .post, parameters: ["role" : "\(USER?.role?.rawValue as! String)"], encoding: JSONEncoding.default, headers: ["Authorization":"Bearer \(UserManager.shared.user!.authenticationToken!)"]).responseJSON { (resp) in
                if(resp.result.value != nil) {
                    if resp.result.value is NSDictionary {
//                        MessageManager.showAlert(nil,"\(String(describing: (resp.result.value as AnyObject).value(forKey: "message"))))")
                        self.lblNoTender.isHidden = false
                    } else {
                        self.lblNoTender.isHidden = true
                        print(resp.result.value!)
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
       
        if isNetworkReachable() {
            self.stopActivityIndicator()
            Alamofire.request(DELETE_TENDER+tender[index].id! , method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: ["Authorization":"Bearer \(UserManager.shared.user!.authenticationToken!)"]).responseJSON { (resp) in
                if(resp.result.value != nil) {
                    if ((resp.result.value as! NSDictionary).allKeys[0] as! String) == "error" {
                        MessageManager.showAlert(nil, "can't add to favorite")
                    } else {
                        self.tender.remove(at: index)
                        self.tblTenderList.reloadData()
                        MessageManager.showAlert(nil, "delete Succesfully")
                    }
                    self.stopActivityIndicator()
                }
            }
        } else {
            MessageManager.showAlert(nil, "No Internet")
        }
    }
}
