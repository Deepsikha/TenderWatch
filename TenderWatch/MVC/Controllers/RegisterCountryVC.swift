//
//  RegisterCountryVC.swift
//  TenderWatch
//
//  Created by Developer88 on 6/22/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit
import ObjectMapper

class RegisterCountryVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var tblvw: UITableView!
    @IBOutlet var btnChoose: UIButton!
    
    @IBOutlet weak var searchCountry: UISearchBar!
    
    var country = [Country]()
    var temp : String?
    
    var filteredCountry = [Country]()
    
    var sectionTitleList = [String]()
    var indexCountry = Dictionary<String, [Country]>()
    
    static var countryCode: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        tblvw.delegate = self
        tblvw.dataSource = self
        tblvw.register(UINib(nibName: "RegisterCountryCell", bundle: nil), forCellReuseIdentifier: "RegisterCountryCell")
        
        self.searchCountry.delegate = self
        
        self.tblvw.tableFooterView = UIView()
        self.tblvw.sectionIndexColor = UIColor.darkGray
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.fetchCoutry()
        self.btnChoose.cornerRedius()
        self.navigationController?.isNavigationBarHidden = true
    }
    
    //MARK:- TableView Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionTitleList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let index = sectionTitleList[section]
        return self.indexCountry[index]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblvw.dequeueReusableCell(withIdentifier: "RegisterCountryCell", for: indexPath) as! RegisterCountryCell
        let index = sectionTitleList[indexPath.section]
        let country = self.indexCountry[index]?[indexPath.row]
        
        cell.countryName.text =
            country?.countryName
        cell.imgFlag.image = UIImage(data: Data(base64Encoded: (country?.imgString!)!)!)
        
        if (USER?.authenticationToken != nil) {
            if (USER?.country == cell.countryName.text) {
                cell.imgTick.isHidden = false
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            } else {
                cell.imgTick.isHidden = true
            }
        } else {
            if (cell.countryName.text == signUpUser.country) {
                cell.imgTick.isHidden = false
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            } else {
                cell.imgTick.isHidden = true
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = sectionTitleList[indexPath.section]
        let
        
        country = self.indexCountry[index]?[indexPath.row]
        
        let cell = tableView.cellForRow(at: indexPath) as! RegisterCountryCell
        if(cell.imgTick.isHidden){
            cell.imgTick.isHidden = !cell.imgTick.isHidden
        }
        if(USER?.authenticationToken != nil) {
            temp = country?.countryName!
        } else {
            signUpUser.country = (country?.countryName!)!
            RegisterCountryVC.countryCode = "+"+(country?.countryCode!)!
        }
        self.searchCountry.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! RegisterCountryCell
        if (!cell.imgTick.isHidden) {
            cell.imgTick.isHidden = !cell.imgTick.isHidden
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sectionTitleList[section]
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.sectionTitleList
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 26
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    
    //MARK: SearchBar Delegate
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        self.tblvw.reloadData()
        return true
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        self.searchCountry.resignFirstResponder()
        self.splitDataInToSection(country: self.country)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredCountry.removeAll(keepingCapacity: false)
        if searchText.isEmpty {
            self.splitDataInToSection(country: self.country)
        } else {
            let array = (self.country as NSArray).filtered(using: NSPredicate(format: "countryName CONTAINS[cd] %@", searchText))
            
            filteredCountry = array as! [Country]
            self.splitDataInToSection(country: filteredCountry)
        }
    }
    
    //MARK:-  IBActions
    @IBAction func bck(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func handleBtnChoose(_ sender: Any) {
        if(USER?.authenticationToken != nil) {
            USER?.country = temp
            RegisterCountryVC.countryCode = "+"+self.country.filter{$0.countryName! == USER?.country}[0].countryCode!
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- Custom Method
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
                    self.splitDataInToSection(country: self.country)
                }
            }) { (errorMessage) in
                print(errorMessage)
                self.stopActivityIndicator()
            }
        } else {
            MessageManager.showAlert(nil, "No Internet")
            self.stopActivityIndicator()
        }
    }
    
    func splitDataInToSection(country: [Country]) {
        var sectionTitle: String = ""
        var arr: [Country] = []
        self.indexCountry = [:]
        self.sectionTitleList = []
        for i in country {
            let currentRecord = i.countryName
            let firstChar = currentRecord?[(currentRecord?.startIndex)!]
            let firstCharString = "\(String(describing: firstChar!))"
            if firstCharString != sectionTitle {
                arr = []
                sectionTitle = firstCharString
                arr.append(i)
                self.indexCountry[sectionTitle] = arr
                self.sectionTitleList.append(sectionTitle)
            } else {
                arr.append(i)
                self.indexCountry[sectionTitle] = arr
            }
        }
        self.stopActivityIndicator()
        self.tblvw.reloadData()
    }
}
