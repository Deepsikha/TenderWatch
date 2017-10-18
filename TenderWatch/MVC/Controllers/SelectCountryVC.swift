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

class SelectCountryVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var tblCountries: UITableView!
    @IBOutlet var btnBack: UIButton!
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet var opnDrwr: UIButton!
    
    var country = [Country]()
    var services = [Services]()
//    var preCountry: [String] = []
    var selectCountry: [String]!
    var amount = 0
    var sectionTitleList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblCountries.delegate = self
        self.tblCountries.dataSource = self
        self.tblCountries.tableFooterView = UIView()
        tblCountries.register(UINib(nibName:"RegisterCountryCell",bundle: nil), forCellReuseIdentifier: "RegisterCountryCell")
    
        btnNext.cornerRedius()
        
        self.getCountry()
        if USER?.authenticationToken == nil {
            self.takeSubscription()
        }
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
            self.lblPrice.text = USER?.subscribe == subscriptionType.free ? "Trial Version" : "$\(self.amount) / \(USER?.subscribe == subscriptionType.monthly ? "month" : "year")"
        } else {
            self.tblCountries.reloadData()
            MappingVC.demoCountry = []
            self.amount = 0
            
            self.lblPrice.text = signUpUser.subscribe == subscriptionType.free.rawValue ? "Trial Version" : "$\(self.amount) / \(signUpUser.subscribe == subscriptionType.monthly.rawValue ? "month" : "year")"
            
            self.opnDrwr.isHidden = true
            self.btnBack.isHidden = false
            self.lblName.isHidden = true
        }
        self.navigationController?.isNavigationBarHidden = true
    }
    
    //MARK: - TableView Method(s)
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1//self.sectionTitleList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return country.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  cell = tableView.dequeueReusableCell(withIdentifier: "RegisterCountryCell", for: indexPath) as! RegisterCountryCell
        cell.countryName.text = self.country[indexPath.row].countryName
        cell.imgTick.isHidden = true
        
//        if USER?.authenticationToken != nil {
//            if (self.preCountry.contains(cell.countryName.text!)) {
//                cell.imgTick.isHidden = false
//                MappingVC.demoCountry.append(self.country[indexPath.row])
//                cell.isUserInteractionEnabled = false
//            } else {
//                cell.imgTick.isHidden = true
//                cell.isUserInteractionEnabled = true
//            }
//        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! RegisterCountryCell
        if (USER?.authenticationToken != nil) {
            if (cell.imgTick.isHidden) {
                cell.imgTick.isHidden = !cell.imgTick.isHidden
                MappingVC.demoCountry.append(self.country[indexPath.row])
                
//                if USER?.subscribe != subscriptionType.free {
////                    self.amount = USER?.subscribe == subscriptionType.monthly ? (MappingVC.demoCountry.count * 15 - self.preCountry.count * 15): (MappingVC.demoCountry.count * 120 - self.preCountry.count * 120)
////                    self.lblPrice.text = "$\(self.amount) / \(USER?.subscribe == subscriptionType.monthly ? "month" : "year")"
//                }
            } else {
                cell.imgTick.isHidden = !cell.imgTick.isHidden
                
                if MappingVC.demoCountry.contains(self.country[indexPath.row]) {
                    
                    if let itemToRemoveIndex = MappingVC.demoCountry.index(of: self.country[indexPath.row]) {
                        MappingVC.demoCountry.remove(at: itemToRemoveIndex)
                        
//                        if USER?.subscribe != subscriptionType.free {
//                            if MappingVC.demoCountry.isEmpty {
//                                self.amount = 0
////                                self.lblPrice.text = "$\(self.amount) / \(signUpUser.subscribe == subscriptionType.monthly.rawValue ? "month" : "year")"
//                            } else {
////                                self.amount = USER?.subscribe == subscriptionType.monthly ? (MappingVC.demoCountry.count * 15 - self.preCountry.count * 15) : (MappingVC.demoCountry.count * 120 - self.preCountry.count * 120)
////                                self.lblPrice.text = "$\(self.amount) / \(signUpUser.subscribe == subscriptionType.monthly.rawValue ? "month" : "year")"
//                            }
//                        }
                    }
                }

            }
        } else {
            if (cell.imgTick.isHidden) {
                cell.imgTick.isHidden = !cell.imgTick.isHidden
                
                MappingVC.demoCountry.append(self.country[indexPath.row])
                
                if signUpUser.subscribe != subscriptionType.free.rawValue {
                    self.amount = signUpUser.subscribe == subscriptionType.monthly.rawValue ? MappingVC.demoCountry.count * 15 : MappingVC.demoCountry.count * 120
                    self.lblPrice.text = "$\(self.amount) / \(signUpUser.subscribe == subscriptionType.monthly.rawValue ? "month" : "year")"
                }
            } else {
                cell.imgTick.isHidden = !cell.imgTick.isHidden
                
                if MappingVC.demoCountry.contains(self.country[indexPath.row]) {
                    
                    if let itemToRemoveIndex = MappingVC.demoCountry.index(of: self.country[indexPath.row]) {
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
            //Api call
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
                MessageManager.showAlert(nil, "During \(signUpUser.subscribe == subscriptionType.monthly.rawValue ? "monthly" : "yearly") subscription you can choose at least 1 Country")
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
                } else if MappingVC.demoCountry.count == 0 {                                        MessageManager.showAlert(nil, "During Free Trial Period you can at least 1 Country")
                } else {
                    MappingVC.demoCountry = MappingVC.demoCountry.sorted(by: { (a, b) -> Bool in
                        a.countryName! < b.countryName!
                    })
                    self.navigationController?.pushViewController(MappingVC(), animated: true)
                }
            } else if MappingVC.demoCountry.isEmpty {
                MessageManager.showAlert(nil, "During \(signUpUser.subscribe == subscriptionType.monthly.rawValue ? "monthly" : "yearly") subscription you can choose at least 1 Country")
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
//                    if USER?.authenticationToken != nil {
////                        self.getServices()
//                    } else {
                        self.stopActivityIndicator()
                        self.tblCountries.reloadData()
//                    }
                }
            }) { (errorMessage) in
                print(errorMessage)
            }
        } else {
            MessageManager.showAlert(nil, "No Internet")
            self.stopActivityIndicator()
        }
    }
    
//    func getServices() {
//        if isNetworkReachable() {
//            Alamofire.request(GET_SERVICES, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(UserManager.shared.user!.authenticationToken!)"]).responseJSON(completionHandler: { (resp) in
//                if(resp.result.value != nil) {
//                    let data = (resp.result.value as! NSObject)
//                    self.services = Mapper<Services>().mapArray(JSONObject: data)!
//                    for i in self.services {
//                        i.countryId = self.country.filter{$0.countryId == i.countryId}[0].countryName
//                        if !self.preCountry.contains(i.countryId!) {
//                            self.preCountry.append(i.countryId!)
//                        }
//                    }
//                    self.tblCountries.reloadData()
//                }
//                self.stopActivityIndicator()
//            })
//        } else {
//            MessageManager.showAlert(nil, "No Internet")
//            self.stopActivityIndicator()
//        }
//    }
    
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
    
    func takeSubscription() {
        let alert = UIAlertController(title: "",
                                      message: "",
                                      preferredStyle: .alert)
        
        // Change font of the title and message
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
        
        
        // Restyle the view of the Alert
        //        alert.view.tintColor = UIColor.brown  // change text color of the buttons
        //        alert.view.backgroundColor = UIColor.cyan  // change background color
        alert.view.layer.cornerRadius = 25   // change corner radius
        
        //         Add action buttons and present the Alert
        alert.addAction(action1)
        alert.addAction(action2)
        alert.addAction(action3)
        
        present(alert, animated: true, completion: nil)
    }

}
