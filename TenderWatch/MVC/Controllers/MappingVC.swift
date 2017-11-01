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
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var tblMappings: UITableView!
    @IBOutlet weak var btnSave: UIButton!
    
    var sectionTitleList = [String]()
    var country = [Country]()
    var category = [Category]()
    static var demoCountry = [Country]()
    var selectedDictionary : Dictionary<String, [String]> = [:]
    var countryCatDict : Dictionary< String, [Category]> = [:]
    var temp : Dictionary< String, [Bool]> = [:]
    var select = [String : [String]]()
    var selectedIndexArray:[IndexPath] = []
    var preSelectedIndexArray:[IndexPath] = []
    
    var sendList = NSMutableDictionary()
    var services = [Services]()
    var updateArray: [IndexPath] = []
    
    static var finalAmt = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblMappings.delegate = self
        self.tblMappings.dataSource = self
        
        self.tblMappings.register(UINib(nibName: "MappingCell", bundle: nil), forCellReuseIdentifier: "MappingCell")
        
        self.tblMappings.tableFooterView = UIView()
        self.fetchCoutry()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.btnSave.cornerRedius()
         if(USER?.authenticationToken != nil) {
            self.btnSave.setTitle("Payment", for: .normal)
            self.lblName.isHidden = false
        } else {
            self.btnSave.setTitle("Next", for: .normal)
            self.lblName.isHidden = true
        }
        self.lblPrice.text = signUpUser.subscribe == subscriptionType.free.rawValue ? "Trial Version" : "$\(MappingVC.finalAmt) / \(signUpUser.subscribe == subscriptionType.monthly.rawValue ? "month" : "year")"
    }
    
    //MARK:- TableView Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.countryCatDict.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let aryForCounting:[Category] = self.countryCatDict[country[section].countryId!]!
        return aryForCounting.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MappingCell", for: indexPath) as! MappingCell
        var arrMapping = self.countryCatDict[country[indexPath.section].countryId!]
        let arrList = arrMapping?[indexPath.row]
        
        cell.imgString.image = UIImage(data: Data(base64Encoded: (arrList?.imgString)!)!)
        
        cell.lblCategory.text =  arrList?.categoryName
        cell.lblCategory.type = .left
        cell.lblCategory.speed = .duration(2)
        cell.lblCategory.animationCurve = .easeInOut
        cell.lblCategory.fadeLength = 0.0
        cell.lblCategory.leadingBuffer = 0.0
        
        if USER?.authenticationToken != nil {
            if preSelectedIndexArray.contains(indexPath) {
                cell.isUserInteractionEnabled = false
            } else {
                cell.isUserInteractionEnabled = true
            }
        }
        
        if (selectedIndexArray.contains(indexPath)) {
            cell.imgTick.isHidden = false
            cell.lblCategory.labelize = false
            cell.lblCategory.fadeLength = 10.0
            cell.lblCategory.leadingBuffer = 0.0
        } else {
            cell.imgTick.isHidden = true
            cell.lblCategory.labelize = true
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (selectedIndexArray.contains(indexPath)) {
            
            selectedIndexArray.remove(at: selectedIndexArray.index(of: indexPath)!)
            if USER?.authenticationToken != nil {
                if updateArray.count > 0 {
                    updateArray.remove(at: updateArray.index(of: indexPath)!)
                }
                if USER?.subscribe == subscriptionType.free {
                    MappingVC.finalAmt = 0
                    self.lblPrice.text = "Trial version"
                } else {
                    MappingVC.finalAmt = signUpUser.subscribe == subscriptionType.monthly.rawValue ? self.updateArray.count * 15 : self.updateArray.count * 120
                    self.lblPrice.text = "$\(MappingVC.finalAmt) / \(signUpUser.subscribe == subscriptionType.monthly.rawValue ? "month" : "year")"
                }
            } else {
                if signUpUser.subscribe != subscriptionType.free.rawValue {
                    if selectedIndexArray.isEmpty {
                        self.lblPrice.text = "$\(MappingVC.finalAmt) / \(signUpUser.subscribe == subscriptionType.monthly.rawValue ? "month" : "year")"
                    } else {
                        if selectedIndexArray.count > self.country.count {
                            MappingVC.finalAmt = signUpUser.subscribe == subscriptionType.monthly.rawValue ? selectedIndexArray.count * 15 : selectedIndexArray.count * 120
                        } else {
                            MappingVC.finalAmt = signUpUser.subscribe == subscriptionType.monthly.rawValue ? self.country.count * 15 : self.country.count * 120
                        }
                        self.lblPrice.text = "$\(MappingVC.finalAmt) / \(signUpUser.subscribe == subscriptionType.monthly.rawValue ? "month" : "year")"
                    }
                }
            }
            
        }
        else {
            selectedIndexArray.append(indexPath)
            
            if USER?.authenticationToken != nil {
                updateArray.append(indexPath)
                if USER?.subscribe == subscriptionType.free {
                    MappingVC.finalAmt = 0
                    self.lblPrice.text = "Trial version"
                } else {
                    MappingVC.finalAmt = signUpUser.subscribe == subscriptionType.monthly.rawValue ? self.updateArray.count * 15 : self.updateArray.count * 120
                    self.lblPrice.text = "$\(MappingVC.finalAmt) / \(signUpUser.subscribe == subscriptionType.monthly.rawValue ? "month" : "year")"
                }
            } else {
                if signUpUser.subscribe != subscriptionType.free.rawValue {
                    if selectedIndexArray.isEmpty {
                        self.lblPrice.text = "$\(MappingVC.finalAmt) / \(signUpUser.subscribe == subscriptionType.monthly.rawValue ? "month" : "year")"
                    } else {
                        if selectedIndexArray.count > self.country.count {
                            MappingVC.finalAmt = signUpUser.subscribe == subscriptionType.monthly.rawValue ? selectedIndexArray.count * 15 : selectedIndexArray.count * 120
                        } else {
                            MappingVC.finalAmt = signUpUser.subscribe == subscriptionType.monthly.rawValue ? self.country.count * 15 : self.country.count * 120
                        }
                        self.lblPrice.text = "$\(MappingVC.finalAmt) / \(signUpUser.subscribe == subscriptionType.monthly.rawValue ? "month" : "year")"
                    }
                }
            }
            
        }
        tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 26
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let country = self.country[section]
        let headerView = UIView()
        headerView.backgroundColor = UIColor.groupTableViewBackground
        let headerFlag = UIImageView(frame: CGRect(x: 4, y: 5, width: 26, height: 16))
        let headerCountry = UILabel(frame: CGRect(x: 36, y: 0, width: self.tblMappings.frame.width - 36, height: 26))
        
        headerView.addSubview(headerFlag)
        headerView.addSubview(headerCountry)
        
        headerCountry.text = country.countryName
        let string = self.country.filter {$0.countryName == country.countryName}[0].imgString
        headerFlag.image = UIImage(data: Data(base64Encoded: string!)!)
        return headerView
        
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.sectionTitleList
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        for cell in self.tblMappings.visibleCells as! [MappingCell] {
            cell.lblCategory.labelize = true
        }
    }
    
    //MARK:- IBActions
    @IBAction func handleBtnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func handleBtnSave(_ sender: Any) {

        select.removeAll()
        if USER?.authenticationToken != nil {
            selectedIndexArray = updateArray
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
                } else if self.select.count == 0 {
                    MessageManager.showAlert(nil, "During Free Trial Period you can choose at least 1 Category.")
                } else {
                    signUpUser.selections = self.select
                    self.navigationController?.pushViewController(RulesVC(), animated: true)
                }
            } else if self.select.isEmpty {
                MessageManager.showAlert(nil, "During \(signUpUser.subscribe == subscriptionType.monthly.rawValue ? "monthly" : "yearly") subscription you can choose at least 1 Category.")
            } else {
                signUpUser.selections = self.select
                PaymentVC.service = signUpUser.selections
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
                    self.country = MappingVC.demoCountry
                    
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
    }

    func getServices() {
        var countries: [String] = []
        let _ = self.country.filter { (a) -> Bool in
            countries.append(a.countryId!)
            return true
        }
        if isNetworkReachable() {
            self.startActivityIndicator()
            Alamofire.request(GET_SERVICES, method: .post, parameters: ["countries": countries], encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(UserManager.shared.user!.authenticationToken!)"]).responseJSON(completionHandler: { (resp) in
                if(resp.result.value != nil) {
                    let data = (resp.result.value as! NSObject)
                    self.services = Mapper<Services>().mapArray(JSONObject: data)!
                    self.services = self.services.sorted(by: { (a, b) -> Bool in
                        a.countryId! > b.countryId!
                    })
                    
                    var cId = ""
                    var catId: [String] = []
                    for ser in self.services {
                        if cId == ser.countryId {
                            for i in ser.categoryId! {
                                catId.append(i)
                            }
                            self.select[cId] = catId
                        } else {
                            self.select[ser.countryId!] = ser.categoryId
                            catId = ser.categoryId!
                        }
                        cId = ser.countryId!
                    }
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
        self.preSelectedIndexArray = self.selectedIndexArray
    }
    
    func updateService() {
        if USER?.subscribe != subscriptionType.free ? self.select.isEmpty : self.preSelectedIndexArray.isEmpty {
            MessageManager.showAlert(nil, "Select at least one new category")
        } else {
            let vc = PaymentVC(nibName: "PaymentVC", bundle: nil)
            if USER?.authenticationToken != nil {
                PaymentVC.service = self.select
            } else {
                PaymentVC.service = signUpUser.selections
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
