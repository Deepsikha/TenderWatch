//
//  SideMenuVC.swift
//  TenderWatch
//
//  Created by devloper65 on 6/22/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage
import Alamofire

class SideMenuVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tblSideMenu: UITableView!
    @IBOutlet var imgProPic: UIImageView!
    @IBOutlet var lblName: UILabel!
    
    static var arrSideMenuIcon: [String] = []
    static var arrSideMenuLbl: [String] = []
    
    var nav1: UINavigationController?
    var nav2: UINavigationController?
    var nav3: UINavigationController?
    var nav4: UINavigationController?
    var nav5: UINavigationController?
    var nav6: UINavigationController?
    var nav7: UINavigationController?
    var nav8: UINavigationController?
    var nav9: UINavigationController?
    var nav10: UINavigationController?

    var count: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tblSideMenu.dataSource = self
        self.tblSideMenu.delegate = self
        
        tblSideMenu.register(UINib(nibName:"SideMenuCell",bundle: nil), forCellReuseIdentifier: "SideMenuCell")
        self.tblSideMenu.tableFooterView = UIView()
        
        if(nav1 == nil){
            nav1 = UINavigationController(rootViewController: TenderWatchVC())
        }
        nav2 = UINavigationController(rootViewController: SubscriptionVC())
        
//        nav3 = UINavigationController(rootViewController: MappingVC())
        nav4 = UINavigationController(rootViewController: UploadTenderVC())
        
        nav5 = UINavigationController(rootViewController: SignUpVC2())
        nav6 = UINavigationController(rootViewController: ChangePasswordVC())
        
        nav7 = UINavigationController(rootViewController: FavoriteVC())
        
        nav8 = UINavigationController(rootViewController: NotificationVC())
        
        nav9 = UINavigationController(rootViewController: HomeVC())
        nav10 = UINavigationController(rootViewController: SupportVC())

        let tap = UITapGestureRecognizer(target: self, action: #selector(self.imageTap))
        tap.cancelsTouchesInView = false
        self.imgProPic.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        self.evo_drawerController?.navigationController?.navigationBar.isHidden = true
        self.tblSideMenu.reloadData()
        
        self.imgProPic.layer.cornerRadius = self.imgProPic.frame.width / 2
        
        self.lblName.text =  USER?.firstName //"Demo User" //remaining
        if (USER?.authenticationToken != nil) {
            self.lblName.text = USER?.email
            if count > 0 {
                self.count = appDelegate.notiNumber + self.count
            } else {
                self.count = appDelegate.notiNumber
            }
            self.imgProPic.sd_setShowActivityIndicatorView(true)
            self.imgProPic.sd_setIndicatorStyle(.gray)
            
            self.imgProPic.sd_setImage(with: URL(string: (USER?.profilePhoto)!), placeholderImage: UIImage(named: "avtar"), options: SDWebImageOptions.progressiveDownload, completed: { (image, error, memory, url) in
            })
        }
        
        if (appDelegate.isClient)! {
            SideMenuVC.arrSideMenuIcon = ["home","upload","userthree","password", "bell", "support", "logout"]
            SideMenuVC.arrSideMenuLbl = ["Home", "Upload Tender", "Edit Profile", "Change Password", "Notifications", "Contact Support Team", "Logout"]
        } else {
            SideMenuVC.arrSideMenuIcon = ["home","dollar", "userthree","password", "fav", "bell", "support", "logout"]
            SideMenuVC.arrSideMenuLbl = ["Home", "Subscription Details", "Edit Profile", "Change Password", "Favorites", "Notifications", "Contact Support Team", "Logout"]
        }
        self.tblSideMenu.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    //MARK:- TableView Delefgate
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
        if cell.lblMenu.text == "Notifications" {
            if count > 0 {
                cell.lblNotify.isHidden = false
                cell.lblNotify.text = "\(count)"
            } else {
                cell.lblNotify.isHidden = true
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? SideMenuCell
        let item = cell?.lblMenu.text
        self.reDirect(item: item!)
    }
    
    // MARK:- custom Method
    func imageTap() {
        appDelegate.drawerController.centerViewController = nav5
        appDelegate.drawerController.closeDrawer(animated: true, completion: { (activation) in
            if (!(USER?.isPayment)!) {
                let vc = UINavigationController(rootViewController: PaymentVC())
                self.nav5?.present(vc, animated: true, completion: nil)
            }
        })
    }
    
    func reDirect(item: String){
        if  item == "Home" {
            appDelegate.drawerController.centerViewController = nav1
            appDelegate.drawerController.closeDrawer(animated: true, completion: { (activation) in
                if appDelegate.isClient! ? false : (!(USER?.isPayment)!) {
                    let vc = UINavigationController(rootViewController: PaymentVC())
                    self.nav1?.present(vc, animated: true, completion: nil)
                }
            })
        } else if item == "Subscription Details" {
            appDelegate.drawerController.centerViewController = nav2
            appDelegate.drawerController.closeDrawer(animated: true, completion: nil)
        } else if  item == "Upload Tender" {
            appDelegate.drawerController.centerViewController = nav4
            appDelegate.drawerController.closeDrawer(animated: true, completion: { (activation) in
                if appDelegate.isClient! ? false : (!(USER?.isPayment)!) {
                    let vc = UINavigationController(rootViewController: PaymentVC())
                    self.nav4?.present(vc, animated: true, completion: nil)
                }
            })
        } else if item == "Edit Profile" {
            appDelegate.drawerController.centerViewController = nav5
            appDelegate.drawerController.closeDrawer(animated: true, completion: { (activation) in
                if appDelegate.isClient! ? false : (!(USER?.isPayment)!) {
                    let vc = UINavigationController(rootViewController: PaymentVC())
                    self.nav5?.present(vc, animated: true, completion: nil)
                }
            })
        } else if item == "Change Password" {
            appDelegate.drawerController.centerViewController = nav6
            appDelegate.drawerController.closeDrawer(animated: true, completion: { (activation) in
                if appDelegate.isClient! ? false : (!(USER?.isPayment)!) {
                    let vc = UINavigationController(rootViewController: PaymentVC())
                    self.nav6?.present(vc, animated: true, completion: nil)
                }
            })
        } else if item == "Favorites" {
            appDelegate.drawerController.centerViewController = nav7
            appDelegate.drawerController.closeDrawer(animated: true, completion: { (activation) in
                if appDelegate.isClient! ? false : (!(USER?.isPayment)!) {
                    let vc = UINavigationController(rootViewController: PaymentVC())
                    self.nav7?.present(vc, animated: true, completion: nil)
                }
            })
        } else if item == "Notifications" {
            count = 0
            appDelegate.notiNumber = 0
            appDelegate.drawerController.centerViewController = nav8
            appDelegate.drawerController.closeDrawer(animated: true, completion: { (activation) in
                if appDelegate.isClient! ? false : (!(USER?.isPayment)!) {
                    let vc = UINavigationController(rootViewController: PaymentVC())
                    self.nav7?.present(vc, animated: true, completion: nil)
                }
            })
        } else if item == "Contact Support Team" {
            appDelegate.drawerController.centerViewController = nav10
            appDelegate.drawerController.closeDrawer(animated: true, completion: nil)
        } else if item == "Logout" {
            Alamofire.request((BASE_URL)+"users", method: .delete, parameters:["deviceId": appDelegate.token,"role": appDelegate.isClient! ? "client" : "contractor"], encoding: JSONEncoding.default, headers: ["Authorization":"Bearer \(UserManager.shared.user!.authenticationToken!)"]).responseJSON(completionHandler: { (resp) in
                if(resp.response?.statusCode == 200) {
                    print("Suucess")
                }
            })
            if appDelegate.isClient! {
                UserDefaults.standard.setValue(USER!.email!, forKey: "eClient")
            } else {
                UserDefaults.standard.setValue(USER!.email!, forKey: "eContractor")
            }
            
            UserManager.shared.logoutCurrentUser()
            //            let nav = UINavigationController(rootViewController: HomeVC())
            
            appDelegate.drawerController.centerViewController = nav9
            self.nav1 = nil
            self.nav2 = nil
            self.nav3 = nil
            self.nav4 = nil
            self.nav5 = nil
            self.nav6 = nil
            self.nav7 = nil
            self.nav8 = nil
            
            appDelegate.drawerController.closeDrawer(animated: true, completion: { (finish) in
                
            })
        }
    }
    
}
