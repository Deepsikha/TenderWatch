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
    var selectedDictionary : Dictionary<String, [String]> = [:]
    var countryCatDict : Dictionary< String, [Category]> = [:]
    var temp : Dictionary< String, [Bool]> = [:]
    var select = [String : [String]]()
    
    var selectedIndexArray:[IndexPath] = []
    
    
    var map = Selections()
    
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
    
    
    func makeCountryDic()
    {
        
        if  country.count != 0{
            for i in 0...country.count - 1{
                countryCatDict[country[i].countryId!] = category
            }
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.countryCatDict.count //self.country.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let aryForCounting:[Category] = self.countryCatDict[country[section].countryId!]!
        return aryForCounting.count
        // return self.category.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RegisterCountryCell", for: indexPath) as! RegisterCountryCell
        var arrMapping = self.countryCatDict[country[indexPath.section].countryId!]
        let arrList = arrMapping?[indexPath.row]
        cell.countryName.text =  arrList?.categoryName//self.category[indexPath.row].categoryName
        if (selectedIndexArray.contains(indexPath))//(arrList?.isSelected)!
        {
            cell.imgTick.isHidden = false
        }
        else
        {
            cell.imgTick.isHidden = true
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        print(indexPath.section)
        //        var arrMapping = self.countryCatDict[country[indexPath.section].countryId!]
        //        let arrList = arrMapping?[indexPath.row]
        //        var temp = [Category]()
        //        self.selectedDictionary[country[indexPath.section].countryId!] = [arrList]
        //        temp = arrMapping!
        //        temp[indexPath.row].isSelected = !(arrMapping?[indexPath.row].isSelected)!
        //        self.countryCatDict[country[indexPath.section].countryId!] = temp
        
        if (selectedIndexArray.contains(indexPath))
        {
            selectedIndexArray.remove(at: selectedIndexArray.index(of: indexPath)!)
        }
        else
        {
            let countryName = country[indexPath.section].countryName!
            print("name:",countryName)
            selectedIndexArray.append(indexPath)
            
        }
        tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
        //        tableView.reloadSections(NSIndexSet(index:indexPath.section) as IndexSet, with: UITableViewRowAnimation.none)
        
        // arrList?.isSelected = !(arrList?.isSelected)!
        // category[indexPath.row].isSelected = !category[indexPath.row].isSelected!
        // tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
        //        let cell = tableView.cellForRow(at: indexPath) as! RegisterCountryCell
        //        if (UserManager.shared.user?.authenticationToken == nil) {
        //            category[indexPath.row].isSelected = !category[indexPath.row].isSelected!
        //            tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
        //
        ////            if category[indexPath.row].isSelected!
        ////            {
        ////                cell.imgTick.isHidden = category[indexPath.row].isSelected!
        ////                category[indexPath.row].isSelected
        ////
        ////            }
        ////            else{
        ////                cell.imgTick.isHidden = category[indexPath.row].isSelected!
        ////            }
        ////            if (cell.imgTick.isHidden) {
        ////                cell.imgTick.isHidden = !cell.imgTick.isHidden
        ////            } else {
        ////                cell.imgTick.isHidden = !cell.imgTick.isHidden
        ////            }
        //
        //        } else {
        //            if (cell.imgTick.isHidden) {
        //                cell.imgTick.isHidden = !cell.imgTick.isHidden
        //                let country1 = tableView.headerView(forSection: indexPath.section)?.textLabel?.text
        //                let category1 = cell.countryName.text!
        //                let id = (self.country.filter {$0.countryName == country1})[0].countryId
        //                let ch = (self.category.filter {$0.categoryName == category1})[0].categoryId
        //
        ////                if self.select.selections.contains(map) {
        ////                    if (map.countryId == id!) {
        ////                        map.categoryId.append(ch!)
        ////                    } else {
        ////                        map = Selections()
        ////                        map.countryId = id!
        ////                        map.categoryId.append(ch!)
        ////                        select.selections.append(map)
        ////                    }
        ////                } else {
        ////                    map.countryId = id!
        ////                    map.categoryId.append(ch!)
        ////                    self.select.selections.append(map)
        ////                }
        ////                if let filteredArray = addCC.filter({$0.countryId == id})
        ////                {
        ////                    if (filteredArray.count > 0)
        ////                    {
        ////                        let newObject:addCountryObj = filteredArray.first!
        ////                        self.lastindexpath = (objMessageListArray?.index(of: newObject))!
        ////                    }
        ////                }
        ////
        ////                if addCC.filter(<#T##isIncluded: (addCountryObj) throws -> Bool##(addCountryObj) throws -> Bool#>) {
        ////
        ////                } else {
        ////                    addCC
        ////                }
        //
        //            } else {
        //                cell.imgTick.isHidden = !cell.imgTick.isHidden
        //                if RulesVC.arrCountry.contains(cell.countryName.text!) {
        //
        //                    if let itemToRemoveIndex = RulesVC.arrCountry.index(of: cell.countryName.text!) {
        //                        RulesVC.arrCountry.remove(at: itemToRemoveIndex)
        //                    }
        //                }
        //            }
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
    
    @IBAction func btnSave(_ sender: Any) {
        select.removeAll()
        if selectedIndexArray.count > 0
        {
            for i in 0...selectedIndexArray.count-1
            {
                var indexPath = selectedIndexArray[i] as IndexPath
                var arrMapping = self.countryCatDict[country[indexPath.section].countryId!]
                if select.keys.contains(country[indexPath.section].countryId!)
                {
                    var tmp = select[country[indexPath.section].countryId!]
                    let arrList = arrMapping?[indexPath.row]
                    tmp?.append((arrList?.categoryId)!)
                    select[country[indexPath.section].countryId!]?.removeAll()
                    select[country[indexPath.section].countryId!] = tmp
                    
                }
                else
                {
                    let arrList = arrMapping?[indexPath.row]
                    var tmp = [String]()
                    tmp.append((arrList?.categoryId)!)
                    select[country[indexPath.section].countryId!] = tmp
                    
                }
            }
            print("dictionary:->",select)
            signUpUser.selections = select
            //selectedIndexArray.removeAll()
            
        }
        self.navigationController?.pushViewController(RulesVC(), animated: true)
    }
    
    
    func fetchCoutry()
    {
        if isNetworkReachable() {
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
            }) { (errorMessage) in
                print(errorMessage)
            }
        } else {
            MessageManager.showAlert(nil, "No Internet")
            self.stopActivityIndicator()
        }
    }
    
    func fetchCategory()
    {
        if isNetworkReachable() {
            self.startActivityIndicator()
            APIManager.shared.requestForGET(url: "auth/category", isTokenEmbeded: false, successHandler: { (finish, res) in
                if res.result.value != nil
                {
                    let data = (res.result.value as! NSObject)
                    self.category = Mapper<Category>().mapArray(JSONObject: data)!
                    self.stopActivityIndicator()
                    self.makeCountryDic()
                    print(self.countryCatDict)
                    self.tblMappings.reloadData()
                }
                
            }) { (errorMessage) in
                print(errorMessage)
            }
        } else {
            MessageManager.showAlert(nil, "No Internet")
            self.stopActivityIndicator()
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
        // self.tblMappings.reloadData()
    }
    
}

