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
    var selectedDictionary : Dictionary<String, [String]> = [:]
    var countryCatDict : Dictionary< String, [Category]> = [:]
    var temp : Dictionary< String, [Bool]> = [:]
    var select = [String : [String]]()
    var selectedIndexArray:[IndexPath] = []
    var services = [Selections]()
    var sendList = NSMutableDictionary()
    
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
            self.btnBack.isHidden = true
            self.btnMenu.isHidden = false
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
        cell.countryName.text =  arrList?.categoryName //self.category[indexPath.row].categoryName
        if (selectedIndexArray.contains(indexPath)) //(arrList?.isSelected)!
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
    
    //MARK:- IBActions
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
            //selectedIndexArray.removeAll()
            
        }
        if (USER?.authenticationToken != nil) {
            self.updateService()
        } else {
            signUpUser.selections = self.select
            self.navigationController?.pushViewController(RulesVC(), animated: true)
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
    
    func fetchCategory()
    {
        if isNetworkReachable() {
            self.startActivityIndicator()
            APIManager.shared.requestForGET(url: CATEGORY, isTokenEmbeded: false, successHandler: { (finish, res) in
                if res.result.value != nil
                {
                    let data = (res.result.value as! NSObject)
                    self.category = Mapper<Category>().mapArray(JSONObject: data)!
                    self.stopActivityIndicator()
                    self.makeCountryDic()
                    print(self.countryCatDict)
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
                    //                    if resp.result.value is NSDictionary {
                    //                        MessageManager.showAlert(nil,"\(String(describing: (resp.result.value as AnyObject).value(forKey: "message"))))")
                    //                    } else {
                    print(resp.result.value!)
                    //                        let data = (resp.result.value as! NSObject)
                    //                        self.services = Mapper<Selections>().mapArray(JSONObject: data)!
                    self.select = resp.result.value as! [String : [String]]
                    print(self.select)
                    self.parse()
                    self.tblMappings.reloadData()
                    //                    }
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
        if isNetworkReachable() {
            Alamofire.request(GET_SERVICES, method: .put, parameters: ["selections" : self.select], encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(UserManager.shared.user!.authenticationToken!)"]).responseJSON(completionHandler: { (resp) in
                //                print(resp.result.value)
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
