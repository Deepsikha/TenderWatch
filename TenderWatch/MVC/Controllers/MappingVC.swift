//
//  MappingVC.swift
//  TenderWatch
//
//  Created by devloper65 on 6/29/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit
import ObjectMapper

class MappingVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var tblMappings: UITableView!
    
    
    var sectionTitleList = [String]()
    var country = [Country]()
    var category = [Category]()
    
    var sendList = NSMutableDictionary()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblMappings.delegate = self
        self.tblMappings.dataSource = self
        
        self.tblMappings.register(UINib(nibName: "RegisterCountryCell", bundle: nil), forCellReuseIdentifier: "RegisterCountryCell")
    
        self.tblMappings.tableFooterView = UIView()
        //taphandle
        //        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapHandler))
        //        tap.cancelsTouchesInView = false
        //        self.view.addGestureRecognizer(tap)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.fetchCoutry()
        self.fetchCategory()
        if(USER?.authenticationToken != nil) {
            self.btnBack.isHidden = true
            self.btnMenu.isHidden = false
        } else {
            self.btnBack.isHidden = false
            self.btnMenu.isHidden = true
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.country.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.category.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RegisterCountryCell", for: indexPath) as! RegisterCountryCell
        
        cell.countryName.text = self.category[indexPath.row].categoryName
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        print(indexPath.section)
        let cell = tableView.cellForRow(at: indexPath) as! RegisterCountryCell
        if (USER?.authenticationToken == nil) {
            if (cell.imgTick.isHidden) {
                cell.imgTick.isHidden = !cell.imgTick.isHidden
            } else {
                cell.imgTick.isHidden = !cell.imgTick.isHidden
            }
            
        } else {
            if (cell.imgTick.isHidden) {
                cell.imgTick.isHidden = !cell.imgTick.isHidden
                let country1 = tableView.headerView(forSection: indexPath.section)?.textLabel?.text
                let category1 = cell.countryName.text!
                let id = (self.country.filter {$0.countryName == country1})[0].countryName
                print(id)
                var arr = [[:]]
                var dictionaryA = [
                    "a": "1",
                    "b": "2",
                    "c": "3",
                    ]
                var dictionaryB = [
                    "a": "4",
                    "b": "5",
                    "c": "6",
                    ]
                var myArray = [[ : ]]
                myArray.append(dictionaryA) // < [!] Expected declaration
                myArray.append(dictionaryB)
                print(myArray)
            } else {
                cell.imgTick.isHidden = !cell.imgTick.isHidden
                if RulesVC.arrCountry.contains(cell.countryName.text!) {
                    
                    if let itemToRemoveIndex = RulesVC.arrCountry.index(of: cell.countryName.text!) {
                        RulesVC.arrCountry.remove(at: itemToRemoveIndex)
                    }
                }
            }
        }
//        {
//            "userId":"594ce471aab7b71e209e5b45",
//            "selections":[
//            {
//            "countryId":"5950ef1fb8b3a71b4ce68a0b",
//            "categoryId":[
//            "5950eea5518d6524ac0f3f28",
//            "5950ee6a518d6524ac0f3f27"
//            ]
//            },
//            {
//            "countryId":"5950ef56b8b3a71b4ce68a0c",
//            "categoryId":[
//            "5950ee44518d6524ac0f3f26",
//            "5950edfe518d6524ac0f3f25"
//            ]
//            }
//            ]
//        }
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let name = self.country[section]
        return name.countryName
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.sectionTitleList
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    
    @IBAction func handleBtnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func handleBtnMenu(_ sender: Any) {
        appDelegate.drawerController.toggleDrawerSide(.left, animated: true, completion: nil)
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
                self.splitDataInToSection()
                self.stopActivityIndicator()
            }
        }) { (erroMessage) in
            
        }
    }
    
    func fetchCategory()
    {
        self.startActivityIndicator()
        APIManager.shared.requestForGET(url: "auth/category", isTokenEmbeded: false, successHandler: { (finish, res) in
            if res.result.value != nil
            {
                let data = (res.result.value as! NSObject)
                self.category = Mapper<Category>().mapArray(JSONObject: data)!
                self.stopActivityIndicator()
                self.tblMappings.reloadData()
            }
            
        }) { (erroMessage) in
            
        }
    }
    
    func splitDataInToSection() {
        
        var sectionTitle: String = ""
        for i in 0..<self.country.count {
            
            let currentRecord = self.country[i].countryName
            let firstChar = currentRecord?[(currentRecord?.startIndex)!]
            let firstCharString = "\(String(describing: firstChar!))"
            if firstCharString != sectionTitle {
                sectionTitle = firstCharString
                self.sectionTitleList.append(sectionTitle)
            }
        }
        self.tblMappings.reloadData()
    }
    
}

