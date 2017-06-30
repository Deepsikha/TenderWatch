//
//  RegisterCountryVC.swift
//  TenderWatch
//
//  Created by Developer88 on 6/22/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit
import ObjectMapper

class RegisterCountryVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tblvw: UITableView!
    
    var country = [Country]()
    @IBOutlet var btnChoose: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        tblvw.delegate = self
        tblvw.dataSource = self
        tblvw.register(UINib(nibName: "RegisterCountryCell", bundle: nil), forCellReuseIdentifier: "RegisterCountryCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.fetchCoutry()
        self.btnChoose.cornerRedius()
        self.navigationController?.isNavigationBarHidden = true
    }
   
    //MARK :- Table Delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.country.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblvw.dequeueReusableCell(withIdentifier: "RegisterCountryCell", for: indexPath) as! RegisterCountryCell
        cell.countryName.text = self.country[indexPath.row].countryName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! RegisterCountryCell
        if(cell.imgTick.isHidden){
            cell.imgTick.isHidden = !cell.imgTick.isHidden
        }
        SignUpVC2.cName = self.country[indexPath.row].countryName
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! RegisterCountryCell
        if (!cell.imgTick.isHidden) {
            cell.imgTick.isHidden = !cell.imgTick.isHidden
        }
    }
    //MARK :-  Button CLick
    @IBAction func bck(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func handleBtnChoose(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func fetchCoutry()
    {
        self.startActivityIndicator()
        APIManager.shared.requestForGET(url: "auth/country", isTokenEmbeded: false, successHandler: { (finish, res) in
            if res.result.value != nil
            {
                let data = (res.result.value as! NSObject)
                self.country = Mapper<Country>().mapArray(JSONObject: data)!
                self.country = self.country.sorted(by: { (a, b) -> Bool in
                    a.countryName! < b.countryName!
                })
                self.stopActivityIndicator()
                self.tblvw.reloadData()
            }
        }) { (erroMessage) in
            
        }
    }

}
