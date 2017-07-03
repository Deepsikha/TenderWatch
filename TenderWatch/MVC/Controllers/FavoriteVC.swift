//
//  FavoriteVC.swift
//  TenderWatch
//
//  Created by LaNet on 6/28/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

class FavoriteVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tblFavorite: UITableView!
    
    var tender = [Tender]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tblFavorite.delegate = self
        self.tblFavorite.dataSource = self
        
        self.tblFavorite.register(UINib(nibName: "TenderListCell", bundle: nil), forCellReuseIdentifier: "TenderListCell")
        
        self.getFavorite()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Table Delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tender.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TenderListCell") as! TenderListCell
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
    //MARK: IBActions
    @IBAction func handleBtnMenu(_ sender: Any) {
        appDelegate.drawerController.toggleDrawerSide(.left, animated: true, completion: nil)
    }
    
    func getFavorite() {
        if isNetworkReachable() {
        Alamofire.request("http://192.168.200.22:4040/api/favourite/getFavourites", method: .post, parameters: nil, encoding: JSONEncoding.default, headers: ["Authorization":"Bearer \(UserManager.shared.user!.authenticationToken!)"]).responseJSON { (resp) in
            if(resp.result.value != nil) {
                if ((resp.result.value as! NSDictionary).allKeys[0] as! String) == "Error" {
                    
                } else {
                    print(resp.result.value!)
                    let data = (resp.result.value as! NSObject)
                    self.tender = Mapper<Tender>().mapArray(JSONObject: data)!
                    
                    self.tblFavorite.reloadData()
                }
            }
        }
        } else {
            MessageManager.showAlert(nil, "No Internet")
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
