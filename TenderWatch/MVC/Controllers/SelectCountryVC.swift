//
//  SelectCountryVC.swift
//  TenderWatch
//
//  Created by lanetteam on 19/06/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit
import ObjectMapper

class SelectCountryVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var tblCountries: UITableView!
    @IBOutlet var btnBack: UIButton!
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet var opnDrwr: UIButton!
    
    var country: [String] = ["Australia", "Belgium", "Brazil", "Canada"]
    var selectCountry: [String]!
    var count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblCountries.delegate = self
        self.tblCountries.dataSource = self
        RulesVC.arrCountry = []
        tblCountries.register(UINib(nibName:"RegisterCountryCell",bundle: nil), forCellReuseIdentifier: "RegisterCountryCell")
        btnNext.cornerRedius()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (USER?.authenticationToken != nil) {
            self.opnDrwr.isHidden = false
            self.btnBack.isHidden = true
            self.lblName.isHidden = false
        } else {
            self.opnDrwr.isHidden = true
            self.btnBack.isHidden = false
            self.lblName.isHidden = true

        }
        self.navigationController?.isNavigationBarHidden = true
    }
    
    //MARK: - TableView Method(s)
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return country.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  cell = tableView.dequeueReusableCell(withIdentifier: "RegisterCountryCell", for: indexPath) as! RegisterCountryCell
        cell.countryName.text = self.country[indexPath.row]
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! RegisterCountryCell
        if (USER?.authenticationToken != nil) {
            if (cell.imgTick.isHidden) {
                cell.imgTick.isHidden = !cell.imgTick.isHidden
            } else {
                cell.imgTick.isHidden = !cell.imgTick.isHidden
            }
            
        } else {
            if (cell.imgTick.isHidden) {
                cell.imgTick.isHidden = !cell.imgTick.isHidden
                
                RulesVC.arrCountry.append(cell.countryName.text!)
                
            } else {
                cell.imgTick.isHidden = !cell.imgTick.isHidden
                
                
                if RulesVC.arrCountry.contains(cell.countryName.text!) {
                    
                    if let itemToRemoveIndex = RulesVC.arrCountry.index(of: cell.countryName.text!) {
                        RulesVC.arrCountry.remove(at: itemToRemoveIndex)
                    }
                }
                
            }
        }
    }
    
    //MARK: - Button CLick
    @IBAction func handleBtnBack(_ sender: Any) {
        if (USER?.authenticationToken != nil) {
            appDelegate.drawerController.toggleDrawerSide(.left, animated: true, completion: nil)

        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func btnNextClick(_ sender: Any) {
        if (USER?.authenticationToken != nil) {
            //Api call
            self.navigationController?.pushViewController(TenderWatchVC(), animated: false)
        } else {
            self.navigationController?.pushViewController(SelectCategoryVC(), animated: true)
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
