//
//  SelectCategory.swift
//  TenderWatch
//
//  Created by devloper65 on 6/23/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit

class SelectCategoryVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var tblCategories: UITableView!
    @IBOutlet var btnBack: UIButton!
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet var opnDrwr: UIButton!
    
    
    var category: [String] = ["Accounting, Banking, Legal", "Building and Trades", "Civil", "Cleaning & Facility Management"]
    var count = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblCategories.delegate = self
        self.tblCategories.dataSource = self
        RulesVC.arrCategory = []
        
        tblCategories.register(UINib(nibName:"RegisterCountryCell",bundle: nil), forCellReuseIdentifier: "RegisterCountryCell")
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
        return category.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  cell = tableView.dequeueReusableCell(withIdentifier: "RegisterCountryCell", for: indexPath) as! RegisterCountryCell
        cell.countryName.text = self.category[indexPath.row]
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
                
                RulesVC.arrCategory.append(cell.countryName.text!)
                
            } else {
                cell.imgTick.isHidden = !cell.imgTick.isHidden
                
                
                if RulesVC.arrCategory.contains(cell.countryName.text!) {
                    
                    if let itemToRemoveIndex = RulesVC.arrCategory.index(of: cell.countryName.text!) {
                        RulesVC.arrCategory.remove(at: itemToRemoveIndex)
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
        self.navigationController?.pushViewController(RulesVC(), animated: true)
    }

}
