//
//  BankPaymentVC.swift
//  TenderWatch
//
//  Created by devloper65 on 9/15/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit
import Stripe
import Alamofire
import ObjectMapper

class BankPaymentVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var tblBankPayments: UITableView!
    @IBOutlet var vwBankDetail: UIView!
    @IBOutlet weak var txfAccountNumber: UITextField!
    @IBOutlet weak var txfHolderName: UITextField!
    @IBOutlet weak var txfRoutingNumber: UITextField!
    @IBOutlet weak var btnSelectCountry: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnAccountType: UIButton!
    @IBOutlet weak var lblDropDown: UILabel!
    @IBOutlet weak var lblDropDownType: UILabel!
    
    @IBOutlet var tblOptions: UITableView!
    var data: [NSDictionary] = []
    var transperentView = UIView()
    var isDropDownActive = false
    var isCountry = true
    var country = [Country]()
    var param = STPBankAccountParams()
    var done: UIBarButtonItem!
    static var price: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblBankPayments.delegate = self
        tblBankPayments.dataSource = self
        
        tblOptions.delegate = self
        tblOptions.dataSource = self
        
        txfHolderName.delegate = self
        txfAccountNumber.delegate = self
        txfRoutingNumber.delegate = self
        
        tblBankPayments.register(UINib(nibName: "RegisterCountryCell", bundle: nil), forCellReuseIdentifier: "RegisterCountryCell")
        tblOptions.register(UINib(nibName: "RegisterCountryCell", bundle: nil), forCellReuseIdentifier: "RegisterCountryCell")
        tblBankPayments.tableFooterView = UIView()
        tblOptions.layer.cornerRadius = 5
        tblOptions.layer.borderColor = UIColor.black.cgColor
        tblOptions.layer.borderWidth = 1
        listBankAccount()
        self.startActivityIndicator()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.hidesBackButton = true
        
        let cancel = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleCancel))
        done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(handleDone))
        done.isEnabled = false
        self.navigationItem.leftBarButtonItems = [cancel]
        self.navigationItem.rightBarButtonItems = [done]
        self.title = "Bank"
        self.btnSave.cornerRedius()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        self.vwBankDetail.center = self.view.center
    }
    
    //MARK:- Tableview delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        if (tableView == self.tblOptions) {
            return 1
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == tblOptions) {
            if self.isCountry {
                return self.country.count
            } else {
                return 2
            }
        } else {
            if (section == 1) {
                return 1
            } else {
                return self.data.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView == self.tblOptions) {
            let cell: RegisterCountryCell = tableView.dequeueReusableCell(withIdentifier: "RegisterCountryCell", for: indexPath) as! RegisterCountryCell
            if (self.isCountry) {
                cell.countryName.text = self.country[indexPath.row].countryName
            } else {
                if indexPath.row == 0 {
                    cell.countryName.text = "Individual"
                } else {
                    cell.countryName.text = "Company"
                }
            }
            return cell
        } else {
            let cell: RegisterCountryCell = tableView.dequeueReusableCell(withIdentifier: "RegisterCountryCell", for: indexPath) as! RegisterCountryCell
            if (indexPath.section == 1) {
                cell.countryName.text = " + Add New Bank Account"
            } else {
                cell.countryName.text = (self.data[indexPath.row] as NSObject).value(forKey: "bank_name") as? String
                cell.imgTick.isHidden = true
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (tableView == self.tblBankPayments) {
            if (section == 0) {
                if self.data.count == 0 {
                    return "No Bank Accounts"
                }
                return "list of Bank"
            }
            return ""
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView == self.tblOptions) {
            if self.isCountry {
                let country = self.country.filter{$0.countryName == self.country[indexPath.row].countryName}[0]
                param.country = country.isoCode
                param.currency = country.isoCurrencyCode
                btnSelectCountry.setTitle(country.countryName, for: .normal)
                lblDropDown.text = "▼"
            } else {
                if indexPath.row == 0 {
                    param.accountHolderType = .individual
                    btnAccountType.setTitle("Individual", for: .normal)
                } else {
                    param.accountHolderType = .company
                    btnAccountType.setTitle("Company", for: .normal)
                }
                lblDropDownType.text = "▼"
            }
            tblOptions.removeFromSuperview()
            isDropDownActive = false
        } else {
            let cell = tableView.cellForRow(at: indexPath) as! RegisterCountryCell
            if(cell.imgTick.isHidden){
                self.done.isEnabled = cell.imgTick.isHidden
                cell.imgTick.isHidden = !cell.imgTick.isHidden
            } else {
                self.done.isEnabled = cell.imgTick.isHidden
                cell.imgTick.isHidden = !cell.imgTick.isHidden
            }
            if (indexPath.section == 1) {
                self.addView()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! RegisterCountryCell
        if tableView == self.tblBankPayments {
            if(!cell.imgTick.isHidden){
                cell.imgTick.isHidden = !cell.imgTick.isHidden
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if tableView == self.tblBankPayments {
            let dlt = UITableViewRowAction(style: .normal, title: "Remove") { action, index in
                print("Edit button tapped")
                if isNetworkReachable() {
                    self.startActivityIndicator()
                    Alamofire.request(PAYMENTS+"bank/charges", method: .delete, parameters: ["bankId": (self.data[indexPath.row] as NSObject).value(forKey: "id")!], encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(UserManager.shared.user!.authenticationToken!)"]).responseJSON(completionHandler: { (resp) in
                        if resp.response?.statusCode == 200 {
                            self.data.remove(at: indexPath.row)
                            self.tblBankPayments.reloadData()
                            self.stopActivityIndicator()
                        } else {
                            self.stopActivityIndicator()
                        }
                    })
                } else {
                    MessageManager.showAlert(nil, "No INternet!!!")
                }
            }
            dlt.backgroundColor = UIColor.red

            return [dlt]
        } else {
            return nil
        }
    }
    
    //MARK:- TextField Delegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.txfAccountNumber {
            param.accountNumber = self.txfAccountNumber.text
        } else if textField == self.txfHolderName {
            param.accountHolderName = self.txfHolderName.text
        } else {
            param.routingNumber = self.txfRoutingNumber.text
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK:- IBActions Methods
    @IBAction func handleBtnCountry(_ sender: Any) {
        let senderButton = sender as! UIButton
        if isDropDownActive == false{
            self.isCountry = true
            self.lblDropDown.text = "▲"
            self.vwBankDetail.addSubview(self.tblOptions)
            let innerRect = self.vwBankDetail.convert(senderButton.frame, from: senderButton.superview);
            self.tblOptions.frame = CGRect(x: innerRect.origin.x, y: innerRect.origin.y + innerRect.height, width: innerRect.width, height: 88)
            self.tblOptions.reloadData()
            self.isDropDownActive = true
        }else{
            lblDropDown.text = "▼"
            tblOptions.removeFromSuperview()
            self.isDropDownActive = false
        }
    }
    
    @IBAction func handleBtnAccountType(_ sender: Any) {
        let senderButton = sender as! UIButton
        if isDropDownActive == false{
            self.isCountry = false
            lblDropDownType.text = "▲"
            self.vwBankDetail.addSubview(self.tblOptions)
            let innerRect = self.vwBankDetail.convert(senderButton.frame, from: senderButton.superview);
            self.tblOptions.frame = CGRect(x: innerRect.origin.x, y: innerRect.origin.y + innerRect.height, width: innerRect.width, height: 88)
            self.tblOptions.reloadData()
            self.isDropDownActive = true
        }else{
            lblDropDownType.text = "▼"
            tblOptions.removeFromSuperview()
            self.isDropDownActive = false
        }
    }
    
    @IBAction func handleBtnPayment(_ sender: Any) {
        self.param.accountHolderName = "Jacob Taylor"
        self.param.routingNumber = "110000000"
        self.param.accountNumber = "000123456789"
        if (self.param.accountNumber != nil && self.param.country != nil && self.param.currency != nil) {
            self.startActivityIndicator()
            STPAPIClient.shared().createToken(withBankAccount: param) { (token, error) in
                if error != nil {
                    MessageManager.showAlert(nil, error!.localizedDescription)
                    self.stopActivityIndicator()
                } else {
                    Alamofire.request(PAYMENTS+"bank/charges", method: .post, parameters: ["token": token!.tokenId], encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(UserManager.shared.user!.authenticationToken!)"]).responseJSON(completionHandler: { (resp) in
                        print(resp)
                        if resp.response?.statusCode == 200 {
                            self.listBankAccount()
                            if self.view.subviews.contains(self.vwBankDetail) {
                                self.vwBankDetail.removeFromSuperview()
                            }
                            if self.view.subviews.contains(self.transperentView) {
                                self.transperentView.removeFromSuperview()
                            }
                        } else {
                            MessageManager.showAlert(nil, "Try Again!!!")
                            self.stopActivityIndicator()
                        }
                    })
                }
            }
        } else {
            if self.param.accountNumber!.isEmpty {
                MessageManager.showAlert(nil, "Account number can't empty")
            } else {
                MessageManager.showAlert(nil, "Country can't empty")
            }
        }
    }
    
    //MARK:- Custom Methods
    func listBankAccount() {
        if isNetworkReachable() {
            Alamofire.request(PAYMENTS+"bank/charges", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(UserManager.shared.user!.authenticationToken!)"]).responseJSON(completionHandler: { (resp) in
                if (resp.response?.statusCode == 500) {
                    self.stopActivityIndicator()
                } else {
                    self.data = ((resp.result.value as! NSObject).value(forKey: "data") as? [NSDictionary])!
                    self.tblBankPayments.reloadData()
                    self.stopActivityIndicator()
                }
            })
        }
    }
    
    func handleCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func handleDone() {
        if isNetworkReachable() {
            self.startActivityIndicator()
            Alamofire.request(PAYMENTS+"bank/charges", method: .post, parameters: ["source": (self.data[(tblBankPayments.indexPathForSelectedRow?.row)!] as NSObject).value(forKey: "id")!, "amount": BankPaymentVC.price], encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(UserManager.shared.user!.authenticationToken!)"]).responseJSON { (resp) in
                self.dismiss(animated: true, completion: {
                    if (resp.response?.statusCode == 500) {
                        MessageManager.showAlert(nil, "Please Try Again!!!")
                        self.stopActivityIndicator()
                    } else {
                        MessageManager.showAlert(nil, "Thank You For Subscribe in Application.")
                        self.stopActivityIndicator()
                    }
                })
            }
        } else {
            MessageManager.showAlert(nil, "No Internet!!!")
        }
    }
    
    func addView() {
        self.transperentView = UIView(frame: UIScreen.main.bounds)
        self.transperentView.backgroundColor = UIColor(red: 85 / 255, green: 85 / 255, blue: 85 / 255, alpha: 0.7)
        if !self.view.subviews.contains(self.transperentView) {
            self.view.addSubview(self.transperentView)
        }
        self.done.isEnabled = false
        view.addSubview(self.vwBankDetail)
        if self.country.count == 0 {
            self.fetchCountry()
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapHandler))
        tap.cancelsTouchesInView = false
        self.transperentView.addGestureRecognizer(tap)
    }
    
    func tapHandler() {
        if self.view.subviews.contains(self.vwBankDetail) {
            self.vwBankDetail.removeFromSuperview()
            if vwBankDetail.subviews.contains(self.tblOptions) {
                tblOptions.removeFromSuperview()
            }
        }
        if self.view.subviews.contains(transperentView) {
            transperentView.removeFromSuperview()
        }
    }
    
    func fetchCountry() {
        self.startActivityIndicator()
        APIManager.shared.requestForGET(url: COUNTRY, isTokenEmbeded: false, successHandler: { (finish, res) in
            if res.result.value != nil
            {
                let data = (res.result.value as! NSObject)
                self.country = Mapper<Country>().mapArray(JSONObject: data)!
                self.country = self.country.sorted(by: { (a, b) -> Bool in
                    a.countryName! < b.countryName!
                })
                self.stopActivityIndicator()
                self.tblOptions.reloadData()
            }
        }) { (errorMessage) in
            print(errorMessage)
            self.stopActivityIndicator()
        }
    }
}
