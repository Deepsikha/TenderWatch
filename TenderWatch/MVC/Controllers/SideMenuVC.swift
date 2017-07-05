//
//  SideMenuVC.swift
//  TenderWatch
//
//  Created by devloper65 on 6/22/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit
import Alamofire

class SideMenuVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tblSideMenu: UITableView!
    @IBOutlet var imgProPic: UIImageView!
    @IBOutlet var lblName: UILabel!
    
    static var arrSideMenuIcon: [String] = []
    static var arrSideMenuLbl: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblSideMenu.dataSource = self
        self.tblSideMenu.delegate = self
        tblSideMenu.register(UINib(nibName:"SideMenuCell",bundle: nil), forCellReuseIdentifier: "SideMenuCell")
        self.tblSideMenu.tableFooterView = UIView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        self.navigationController?.navigationBar.isHidden = true
        self.evo_drawerController?.navigationController?.navigationBar.isHidden = true
        self.tblSideMenu.reloadData()
        
        self.imgProPic.layer.cornerRadius = self.imgProPic.frame.width / 2
        self.imgProPic.layer.borderColor = UIColor.black.cgColor
        self.imgProPic.layer.borderWidth = 2

        self.lblName.text =  USER?.firstName //"Demo User" //remaining
        if (USER?.authenticationToken != nil) {
//            let url = "192.168.200.22:4040/api/users/images?url=\((user.self as! User).profilePhoto!)"
//            Alamofire.request("http://192.168.200.22:4040/api/users/images?url=/images/mike.jpg", method: .get, parameters: [:], encoding: JSONEncoding.default, headers: ["Authorization": AppDelegate.apiToken!]).responseData(completionHandler: { (resp) in
//                if (resp.result.value != nil) {
//                    print(resp.result.value!)
//                }
//            })
            
            self.imgProPic.image = UIImage(named: "avtar")
        } else {
            self.imgProPic.image = UIImage(named: "avtar")
        }
        
        if (appDelegate.isClient)! {
            SideMenuVC.arrSideMenuIcon = ["home","upload","userthree","password", "bell", "logout"]
            SideMenuVC.arrSideMenuLbl = ["Home", "Upload Tender", "Edit Profile", "Change Password", "Notifications", "Logout"]
        } else {
            SideMenuVC.arrSideMenuIcon = ["home","dollar","flag", "userthree","password", "fav", "bell", "logout"]
            SideMenuVC.arrSideMenuLbl = ["Home", "Subscription Details", "Add/Remove Countries", "Edit Profile", "Change Password", "Favorites", "Notifications", "Logout"]
        }
        self.tblSideMenu.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK:- TableView Method(s)
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  SideMenuVC.arrSideMenuLbl.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuCell", for: indexPath) as! SideMenuCell
        cell.lblMenu.text = SideMenuVC.arrSideMenuLbl[indexPath.row]
        cell.imgIcon.image = UIImage(named: SideMenuVC.arrSideMenuIcon[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? SideMenuCell
        let item = cell?.lblMenu.text
        self.reDirect(item: item!)
    }
    
    // MARK:- IBOutlet Method(s)
    
    func reDirect(item: String){
        if  item == "Home" {
            let nav = UINavigationController(rootViewController: TenderWatchVC())
            appDelegate.drawerController.centerViewController = nav
            appDelegate.drawerController.closeDrawer(animated: true, completion: nil)
        } else if item == "Subscription Details" {
            let nav = UINavigationController(rootViewController: SubscriptionVC())
            appDelegate.drawerController.centerViewController = nav
            appDelegate.drawerController.closeDrawer(animated: true, completion: nil)
        } else if item == "Add/Remove Countries" {
            let nav = UINavigationController(rootViewController: MappingVC())
            appDelegate.drawerController.centerViewController = nav
            appDelegate.drawerController.closeDrawer(animated: true, completion: nil)
        }  else if item == "Add/Remove Categories" {
            let nav = UINavigationController(rootViewController: SelectCategoryVC())
            appDelegate.drawerController.centerViewController = nav
            appDelegate.drawerController.closeDrawer(animated: true, completion: nil)
        } else if  item == "Upload Tender" {
            let nav = UINavigationController(rootViewController: UploadTenderVC())
            appDelegate.drawerController.centerViewController = nav
            appDelegate.drawerController.closeDrawer(animated: true, completion: nil)
        } else if item == "Edit Profile" {
            DispatchQueue.main.async {
                
            let nav = UINavigationController(rootViewController: SignUpVC2())
            appDelegate.drawerController.centerViewController = nav
            appDelegate.drawerController.closeDrawer(animated: true, completion: nil)
            }
        } else if item == "Change Password" {
            let nav = UINavigationController(rootViewController: ChangePasswordVC())
            appDelegate.drawerController.centerViewController = nav
            appDelegate.drawerController.closeDrawer(animated: true, completion: nil)
        } else if item == "Favorites" {
            let nav = UINavigationController(rootViewController: FavoriteVC())
            appDelegate.drawerController.centerViewController = nav
            appDelegate.drawerController.closeDrawer(animated: true, completion: nil)
        } else if item == "Notifications" {
            let nav = UINavigationController(rootViewController: NotificationVC())
            appDelegate.drawerController.centerViewController = nav
            appDelegate.drawerController.closeDrawer(animated: true, completion: nil)
        } else if item == "Logout" {
            UserManager.shared.logoutCurrentUser()
            let nav = UINavigationController(rootViewController: HomeVC())
            appDelegate.drawerController.centerViewController = nav
            appDelegate.drawerController.closeDrawer(animated: false, completion: nil)
        }
    }

}
