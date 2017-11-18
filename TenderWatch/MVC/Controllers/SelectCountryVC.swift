//
//  SelectCountryVC.swift
//  TenderWatch
//
//  Created by lanetteam on 19/06/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit
import ObjectMapper
import Alamofire

class SelectCountryVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var tblCountries: UITableView!
    @IBOutlet var btnBack: UIButton!
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet var opnDrwr: UIButton!
    @IBOutlet weak var searchCountry: UISearchBar!
    
    var country = [Country]()
    var filterCountry = [Country]()
    var services = [Services]()
    var selectCountry: [String]!
    var amount = 0
    var sectionTitleList = [String]()
    var indexCountry = Dictionary<String, [Country]>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblCountries.delegate = self
        self.tblCountries.dataSource = self
        self.tblCountries.tableFooterView = UIView()
        tblCountries.register(UINib(nibName:"RegisterCountryCell",bundle: nil), forCellReuseIdentifier: "RegisterCountryCell")
        
        btnNext.cornerRedius()
        
        self.getCountry()
        self.takeSubscription()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (USER?.authenticationToken != nil) {
            self.opnDrwr.isHidden = false
            self.btnBack.isHidden = true
            self.lblName.isHidden = false
            self.lblPrice.isHidden = true
            self.amount = 0
            MappingVC.demoCountry = []
            self.tblCountries.reloadData()
        } else {
            self.tblCountries.reloadData()
            MappingVC.demoCountry = []
            self.amount = 0
            self.opnDrwr.isHidden = true
            self.btnBack.isHidden = false
            self.lblName.isHidden = true
        }
        self.lblPrice.text = signUpUser.subscribe == subscriptionType.free.rawValue ? "Trial Version" : "$\(self.amount) / \(signUpUser.subscribe == subscriptionType.monthly.rawValue ? "month" : "year")"
        self.navigationController?.isNavigationBarHidden = true
    }
    
    //MARK: SearchBar Delegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let textField:UITextField = searchBar.value(forKey: "_searchField") as! UITextField
        textField.clearButtonMode = .never
        if !searchText.isEmpty{
            filterCountry = country.filter {($0.countryName?.contains(searchText))!}
            if filterCountry.count > 0 {
                self.splitDataInToSection(country: self.filterCountry)
            }
        }else{
            filterCountry = country
            self.splitDataInToSection(country: country)
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    
    
    
    //MARK: - TableView Method(s)
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitleList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let index = sectionTitleList[section]
        return self.indexCountry[index]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  cell = tableView.dequeueReusableCell(withIdentifier: "RegisterCountryCell", for: indexPath) as! RegisterCountryCell
        let index = sectionTitleList[indexPath.section]
        let country = self.indexCountry[index]?[indexPath.row]
        cell.countryName.text = country?.countryName
        cell.imgTick.isHidden = true
        cell.imgFlag.image = UIImage(data: Data(base64Encoded: (country?.imgString!)!)!)
        if MappingVC.demoCountry.contains(country!) {
            cell.imgTick.isHidden = false
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! RegisterCountryCell
        let index = sectionTitleList[indexPath.section]
        let country = self.indexCountry[index]?[indexPath.row]
        if (USER?.authenticationToken != nil) {
            if (cell.imgTick.isHidden) {
                cell.imgTick.isHidden = !cell.imgTick.isHidden
                MappingVC.demoCountry.append(country!)
            } else {
                cell.imgTick.isHidden = !cell.imgTick.isHidden
                
                if MappingVC.demoCountry.contains(country!) {
                    
                    if let itemToRemoveIndex = MappingVC.demoCountry.index(of: country!) {
                        MappingVC.demoCountry.remove(at: itemToRemoveIndex)
                    }
                }
                
            }
        } else {
            if (cell.imgTick.isHidden) {
                cell.imgTick.isHidden = !cell.imgTick.isHidden
                
                MappingVC.demoCountry.append(country!)
                
                if signUpUser.subscribe != subscriptionType.free.rawValue {
                    self.amount = signUpUser.subscribe == subscriptionType.monthly.rawValue ? MappingVC.demoCountry.count * 15 : MappingVC.demoCountry.count * 120
                    self.lblPrice.text = "$\(self.amount) / \(signUpUser.subscribe == subscriptionType.monthly.rawValue ? "month" : "year")"
                }
            } else {
                cell.imgTick.isHidden = !cell.imgTick.isHidden
                
                if MappingVC.demoCountry.contains(country!) {
                    
                    if let itemToRemoveIndex = MappingVC.demoCountry.index(of: country!) {
                        MappingVC.demoCountry.remove(at: itemToRemoveIndex)
                        
                        if signUpUser.subscribe != subscriptionType.free.rawValue {
                            if MappingVC.demoCountry.isEmpty {
                                self.amount = 0
                                self.lblPrice.text = "$\(self.amount) / \(signUpUser.subscribe == subscriptionType.monthly.rawValue ? "month" : "year")"
                            } else {
                                self.amount = signUpUser.subscribe == subscriptionType.monthly.rawValue ? MappingVC.demoCountry.count * 15 : MappingVC.demoCountry.count * 120
                                self.lblPrice.text = "$\(self.amount) / \(signUpUser.subscribe == subscriptionType.monthly.rawValue ? "month" : "year")"
                            }
                        }
                    }
                }
            }
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
    
    //MARK: - IBButtonAction
    @IBAction func handleBtnBack(_ sender: Any) {
        if (USER?.authenticationToken != nil) {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func btnNextClick(_ sender: Any) {
        MappingVC.finalAmt = self.amount
        if (USER?.authenticationToken != nil) {
            if USER?.subscribe == subscriptionType.free {
                if MappingVC.demoCountry.count > 1 {
                    MessageManager.showAlert(nil, "During Free Trial Period you can choose only 1 Country")
                } else {
                    MappingVC.demoCountry = MappingVC.demoCountry.sorted(by: { (a, b) -> Bool in
                        a.countryName! < b.countryName!
                    })
                    self.navigationController?.pushViewController(MappingVC(), animated: true)
                }
            } else if MappingVC.demoCountry.isEmpty {
                MessageManager.showAlert(nil, "You have to choose at least 1 Country")
            } else {
                MappingVC.demoCountry = MappingVC.demoCountry.sorted(by: { (a, b) -> Bool in
                    a.countryName! < b.countryName!
                })
                self.navigationController?.pushViewController(MappingVC(), animated: true)
            }
        } else {
            if signUpUser.subscribe == subscriptionType.free.rawValue {
                if MappingVC.demoCountry.count > 1 {
                    MessageManager.showAlert(nil, "During Free Trial Period you can choose only 1 Country")
                } else if MappingVC.demoCountry.count == 0 {                                        MessageManager.showAlert(nil, "During Free Trial Period you have to choose 1 Country")
                } else {
                    MappingVC.demoCountry = MappingVC.demoCountry.sorted(by: { (a, b) -> Bool in
                        a.countryName! < b.countryName!
                    })
                    self.navigationController?.pushViewController(MappingVC(), animated: true)
                }
            } else if MappingVC.demoCountry.isEmpty {
                MessageManager.showAlert(nil, "You have to choose at least 1 Country ")
            } else {
                MappingVC.demoCountry = MappingVC.demoCountry.sorted(by: { (a, b) -> Bool in
                    a.countryName! < b.countryName!
                })
                self.navigationController?.pushViewController(MappingVC(), animated: true)
            }
        }
    }
    
    //MARK:- Custom Merthods
    func getCountry() {
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
                    self.stopActivityIndicator()
                    self.tblCountries.reloadData()
                    
                }
            }) { (errorMessage) in
                print(errorMessage)
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
        self.tblCountries.reloadData()
    }
    
    func takeSubscription() {
        let alert = UIAlertController(title: "",
                                      message: "",
                                      preferredStyle: .alert)
        
        let titleFont:[String : AnyObject] = [ NSFontAttributeName : UIFont(name: "AmericanTypewriter", size: 18)! ]
        let messageFont:[String : AnyObject] = [ NSFontAttributeName : UIFont(name: "HelveticaNeue-Thin", size: 14)! ]
        let attributedTitle = NSMutableAttributedString(string: "TenderWatch", attributes: titleFont)
        let attributedMessage = NSMutableAttributedString(string: "Select a Subscription plan", attributes: messageFont)
        alert.setValue(attributedTitle, forKey: "attributedTitle")
        alert.setValue(attributedMessage, forKey: "attributedMessage")
        
        let action1 = UIAlertAction(title: "1 month free trial", style: .default, handler: { (action) -> Void in
            signUpUser.subscribe = subscriptionType.free.rawValue
            self.lblPrice.text = "Trial Version"
        })
        
        let action2 = UIAlertAction(title: "Monthly subscription ($15 / month)", style: .default, handler: { (action) -> Void in
            signUpUser.subscribe = subscriptionType.monthly.rawValue
            self.lblPrice.text = "$\(self.amount) / month"
        })
        
        let action3 = UIAlertAction(title: "Yearly subscription ($120 / Year)", style: .default, handler: { (action) -> Void in
            signUpUser.subscribe = subscriptionType.yearly.rawValue
            self.lblPrice.text = "$\(self.amount) / year"
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alert.view.layer.cornerRadius = 25   // change corner radius
        if USER?.authenticationToken == nil {
            alert.addAction(action1)
        }
        alert.addAction(action2)
        alert.addAction(action3)
        if USER?.authenticationToken != nil {
            alert.addAction(cancel)
        }
        
        present(alert, animated: true, completion: nil)
    }
    
}
