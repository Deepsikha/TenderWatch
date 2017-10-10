//
//  MappingVC.swift
//  TenderWatch
//
//  Created by devloper65 on 6/29/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit
import ObjectMapper
import Alamofire

class MappingVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var tblMappings: UITableView!
    
    var sectionTitleList = [String]()
    var country = [Country]()
    var category = [Category]()
    static var demoCountry = [Country]()
    var selectedDictionary : Dictionary<String, [String]> = [:]
    var countryCatDict : Dictionary< String, [Category]> = [:]
    var temp : Dictionary< String, [Bool]> = [:]
    var select = [String : [String]]()
    var selectedIndexArray:[IndexPath] = []
    
    var sendList = NSMutableDictionary()
    var services = [Services]()
    var updateArray = [String : [String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblMappings.delegate = self
        self.tblMappings.dataSource = self
        
        self.tblMappings.register(UINib(nibName: "RegisterCountryCell", bundle: nil), forCellReuseIdentifier: "RegisterCountryCell")
        
        self.tblMappings.tableFooterView = UIView()
        self.fetchCoutry()
        
        //taphandle
        //        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapHandler))
        //        tap.cancelsTouchesInView = false
        //        self.view.addGestureRecognizer(tap)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        
        if(USER?.authenticationToken != nil) {
            self.btnBack.isHidden = false
            self.btnMenu.isHidden = true
        } else {
            self.btnBack.isHidden = false
            self.btnMenu.isHidden = true
        }
    }
    
    //MARK:- TableView Delegate
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
//        cell.countryName.labelize = true
        cell.countryName.text =  arrList?.categoryName //self.category[indexPath.row].categoryName
        cell.countryName.type = .left
        cell.countryName.speed = .duration(2)
        cell.countryName.animationCurve = .easeInOut
        cell.countryName.fadeLength = 0.0
        cell.countryName.leadingBuffer = 0.0
        
        if (selectedIndexArray.contains(indexPath)) {
            cell.imgTick.isHidden = false
            cell.countryName.labelize = false
            cell.countryName.fadeLength = 10.0
            cell.countryName.leadingBuffer = 0.0
        } else {
            cell.imgTick.isHidden = true
            cell.countryName.labelize = true
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        for cell in self.tblMappings.visibleCells as! [RegisterCountryCell] {
            cell.countryName.labelize = true
        }
    }
    //MARK:- IBActions
    @IBAction func handleBtnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func handleBtnMenu(_ sender: Any) {
        appDelegate.drawerController.toggleDrawerSide(.left, animated: true, completion: nil)
    }
    
    @IBAction func btnSave(_ sender: Any) {

        select.removeAll()
        if USER?.authenticationToken != nil {
            signUpUser.subscribe = (USER?.subscribe)!.rawValue
        }
        if selectedIndexArray.count > 0
        {
            if signUpUser.subscribe != subscriptionType.free.rawValue && signUpUser.subscribe != subscriptionType.none.rawValue{
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
            //selectedIndexArray.removeAll()
            } else {
                if (signUpUser.subscribe == subscriptionType.free.rawValue){
                    if selectedIndexArray.count > 1 {
                        MessageManager.showAlert(nil, "During Free Trial Period you can choose only 1 Category.")
                    } else {
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
                    }
                }
            }
        }
        
        if (USER?.authenticationToken != nil) {
            self.updateService()
        } else {
            if signUpUser.subscribe == subscriptionType.free.rawValue {
                if self.select.count > 1 {
                    MessageManager.showAlert(nil, "During Free Trial Period you can choose only 1 Category.")
                } else {
                    signUpUser.selections = self.select
                    self.navigationController?.pushViewController(RulesVC(), animated: true)
                }
            } else if self.select.isEmpty {
                MessageManager.showAlert(nil, "During \(signUpUser.subscribe == subscriptionType.monthly.rawValue ? "monthly" : "yearly") subscription you can choose at least 1 Category.")
            } else {
                signUpUser.selections = self.select
                self.navigationController?.pushViewController(RulesVC(), animated: true)
            }
        }
    }
    
    //MARK:- Custom Method
    func makeCountryDic()
    {
        if  country.count != 0{
            for i in 0...country.count - 1{
                countryCatDict[country[i].countryId!] = category
            }
        }
    }
    
    func fetchCoutry()
    {
        if isNetworkReachable() {
            self.startActivityIndicator()
            APIManager.shared.requestForGET(url: COUNTRY, isTokenEmbeded: false, successHandler: { (finish, res) in
                if res.result.value != nil
                {
                    let data = (res.result.value as! NSObject)
                    self.country = Mapper<Country>().mapArray(JSONObject: data)!
                    self.country = self.country.sorted(by: { (a, b) -> Bool in
                        a.countryName! < b.countryName!
                    })
                    if USER?.authenticationToken == nil {
                        self.country = MappingVC.demoCountry
                    }
                    self.splitDataInToSection()
                    self.stopActivityIndicator()
                    self.fetchCategory()
                    
                }
            }) { (errorMessage) in
                print(errorMessage)
            }
        } else {
            MessageManager.showAlert(nil, "No Internet")
            self.stopActivityIndicator()
        }
    }
    
    func fetchCategory() {
        if isNetworkReachable() {
            self.startActivityIndicator()
            APIManager.shared.requestForGET(url: CATEGORY, isTokenEmbeded: false, successHandler: { (finish, res) in
                if res.result.value != nil
                {
                    let data = (res.result.value as! NSObject)
                    self.category = Mapper<Category>().mapArray(JSONObject: data)!
                    self.stopActivityIndicator()
                    self.makeCountryDic()
                    if (USER?.authenticationToken != nil) {
                        self.getServices()
                    }
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

    func getServices() {
        if isNetworkReachable() {
            self.startActivityIndicator()
            Alamofire.request(GET_SERVICES, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(UserManager.shared.user!.authenticationToken!)"]).responseJSON(completionHandler: { (resp) in
                if(resp.result.value != nil) {
                    let data = (resp.result.value as! NSObject)
                    self.services = Mapper<Services>().mapArray(JSONObject: data)!
                    for ser in self.services {
                        self.select[ser.countryId!] = ser.categoryId
                    }
                    self.updateArray = self.select
//                    var arr: [String] = []
//                    for i in self.services {
//                        arr.removeAll()
//                        i.countryId = self.country.filter{$0.countryId == i.countryId}[0].countryName
//                        for j in i.categoryId! {
//                            let category = self.category.filter{$0.categoryId == j}[0].categoryName
//                            arr.append(category!)
//                        }
//                        i.categoryId = arr
//                    }
                    
                    print(self.select)
                    self.parse()
                    self.tblMappings.reloadData()
                }
                print(resp.result)
                self.stopActivityIndicator()
            })
        } else {
            MessageManager.showAlert(nil, "No Internet")
        }
    }
    
    func parse() {
        for i in self.select {
            let country = self.country.filter{$0.countryId == i.key}[0]
            let section = self.country.index(of: country)
            for j in i.value {
                let category = self.category.filter{$0.categoryId == j}[0]
                let row = self.category.index(of: category)
                selectedIndexArray.append(IndexPath(row: row!, section: section!))
            }
        }
    }
    
    func updateService() {
        
        var newSelectArray = [String : [String]]()

        for key1 in self.select.keys {
            for key2 in updateArray.keys {
                if key1 == key2 {
                    let valueArray1 = self.select[key1]
                    let valueArray2 = updateArray[key2]
                    let filteredCategoryArray = valueArray1?.filter({ (categoryvalue) -> Bool in
                        if (valueArray2?.contains(categoryvalue))!{
                            return false
                        }
                        return true
                    })
                    
                    if filteredCategoryArray!.count > 0 {
                        newSelectArray[key1] = filteredCategoryArray
                    }
                } else {
                    newSelectArray[key1] = self.select[key1]
                }
            }
            
            print(newSelectArray)
        }
        
//        for i in updateArray {
//            let data = self.select.filter({ (select) -> Bool in
//                if select.key == i.key {
//                    var arr = select.value
//                    for j in i.value {
//                            if arr.contains(j) {
//                                arr.remove(at: i.value.index(of: j)!)
//                            }
//                    }
//                    select.value = arr
//                }
//                return true
//            })
//        }

        if isNetworkReachable() {
            Alamofire.request(GET_SERVICES, method: .put, parameters: ["selections" : newSelectArray], encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(UserManager.shared.user!.authenticationToken!)"]).responseJSON(completionHandler: { (resp) in
                if (resp.response?.statusCode == 200) {
                    appDelegate.setHomeViewController()
                } else {
                    MessageManager.showAlert(nil, "Services can't Updated.")
                }
            })
        } else {
            MessageManager.showAlert(nil, "No Internet!!!")
        }
    }
    
}
