//
//  SubscriptionVC.swift
//  TenderWatch
//
//  Created by devloper65 on 6/26/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import PassKit
import PDFReader

class SubscriptionVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var btnPayment: UIButton!
    @IBOutlet weak var tblSubscription: UITableView!
    
    @IBOutlet weak var vwPDF: UIView!
    var country = [Country]()
    var category = [Category]()
    var sectionTitleList = [String]()
    var services = [Services]()
    
    var shippingManager = ShippingManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tblSubscription.delegate = self
        self.tblSubscription.dataSource = self
        
        self.tblSubscription.register(UINib(nibName: "MappingCell", bundle: nil), forCellReuseIdentifier: "MappingCell")
        self.tblSubscription.tableFooterView = UIView()
        
        title = "Invoice"
        self.fetchCoutry()
        self.createPDF()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- TableView Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.services.count //self.country.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.services[section].categoryId?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MappingCell", for: indexPath) as! MappingCell
        let ser = self.services[indexPath.section]
        
        cell.imgString.image = UIImage(data: Data(base64Encoded: self.category.filter { $0.categoryName! == (ser.categoryId?[indexPath.row])!}[0].imgString!)!)
        cell.lblCategory.text = ser.categoryId?[indexPath.row]
        cell.imgTick.isHidden = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let country = self.services[section]
        let headerView = UIView()
        headerView.backgroundColor = UIColor.groupTableViewBackground
        let headerFlag = UIImageView(frame: CGRect(x: 4, y: 5, width: 26, height: 16))
        let headerCountry = UILabel(frame: CGRect(x: 36, y: 0, width: self.tblSubscription.frame.width - 36, height: 26))
        
        headerView.addSubview(headerFlag)
        headerView.addSubview(headerCountry)
        
        headerCountry.text = country.countryId
        let string = self.country.filter {$0.countryName == country.countryId}[0].imgString
        headerFlag.image = UIImage(data: Data(base64Encoded: string!)!)
        return headerView

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
   
    //MARK:- IBActions
    @IBAction func handleBtnMenu(_ sender: Any) {
        appDelegate.drawerController.toggleDrawerSide(.left, animated: true, completion: nil)
    }
    
    @IBAction func handleBtnPayment(_ sender: Any) {
        let vc = UINavigationController(rootViewController: SelectCountryVC())
        self.present(vc, animated: true, completion: nil)
    }
    
    //MARK:- Custom Methods
    func fetchCoutry() {
        if isNetworkReachable() {
            self.startActivityIndicator()
            APIManager.shared.requestForGET(url: COUNTRY, isTokenEmbeded: false, successHandler: { (finish, res) in
                if res.result.value != nil
                {
                    let data = (res.result.value as! NSObject)
                    self.country = Mapper<Country>().mapArray(JSONObject: data)!
                    self.fetchCategory()
                }
            }) { (errorMessage) in
                print(errorMessage)
            }
        } else {
            MessageManager.showAlert(nil, "No Internet")
        }
    }
    
    func fetchCategory() {
        if isNetworkReachable() {
            APIManager.shared.requestForGET(url: CATEGORY, isTokenEmbeded: false, successHandler: { (finish, res) in
                if res.result.value != nil
                {
                    let data = (res.result.value as! NSObject)
                    self.category = Mapper<Category>().mapArray(JSONObject: data)!
                    self.getServices()
                }
            }) { (errorMessage) in
                print(errorMessage)
            }
        } else {
            MessageManager.showAlert(nil, "No Internet")
        }
    }
    
    func getServices() {
        if isNetworkReachable() {
            Alamofire.request(GET_SERVICES, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(UserManager.shared.user!.authenticationToken!)"]).responseJSON(completionHandler: { (resp) in
                if(resp.response?.statusCode == 200) {
                    let data = (resp.result.value as! NSObject)
                    self.services = Mapper<Services>().mapArray(JSONObject: data)!
                    self.parse()
                } else {
                    MessageManager.showAlert("nil", "Try Again!!!")
                    self.stopActivityIndicator()
                }

            })
        } else {
            MessageManager.showAlert(nil, "No Internet")
        }
    }
    
    func parse() {
        var arr: [String] = []
        var count: Int = 0
        for i in self.services {
            arr.removeAll()
            i.countryId = self.country.filter{$0.countryId == i.countryId}[0].countryName
            for j in i.categoryId! {
                let category = self.category.filter{$0.categoryId == j}[0].categoryName
                arr.append(category!)
                count = count + 1
            }
            i.categoryId = arr
        }
        
        self.services = self.services.sorted(by: { (a, b) -> Bool in
            a.countryId! < b.countryId!
        })
        
        var cId: String = ""
        var catId: [String] = []
        var arrSelectSort = [Services]()
        for ser in self.services {
            if cId == ser.countryId {
                for i in ser.categoryId! {
                    catId.append(i)
                }
                arrSelectSort.filter {$0.countryId == cId}[0].categoryId = catId
            } else {
                arrSelectSort.append(ser)
                catId = ser.categoryId!
            }
            cId = ser.countryId!
        }
        self.services = arrSelectSort
        self.splitDataInToSection()
    }
    
    func splitDataInToSection() {
        var sectionTitle: String = ""
        for i in 0..<self.services.count {
            let currentRecord = self.services[i].countryId
            let firstChar = currentRecord?[(currentRecord?.startIndex)!]
            let firstCharString = "\(String(describing: firstChar!))"
            if firstCharString != sectionTitle {
                sectionTitle = firstCharString
                self.sectionTitleList.append(sectionTitle)
            }
        }
        self.stopActivityIndicator()
        self.tblSubscription.reloadData()
    }
    
    func createPDF() {
        if USER?.invoiceURL != nil {
         let data = PDFDocument(url: URL(string: (USER?.invoiceURL)!)!)
            let cntrl = PDFViewController.createNew(with: data!, title: "Subscription")
            cntrl.scrollDirection = .vertical
            cntrl.backgroundColor = UIColor.white
            self.addChildViewController(cntrl)
            cntrl.view.frame = self.vwPDF.bounds
            self.vwPDF.addSubview(cntrl.view)
        }
    }
}

class ShippingManager: NSObject {
    func defaultShippingMethods() -> [Any] {
        return californiaShippingMethods()
    }
    func fetchShippingCosts(forAddress address: CNPostalAddress, completion: @escaping (_ shippingMethods: [Any], _ error: Error?) -> Void) {
        let state = address.state
        
        if (state == "CA") {
            completion(californiaShippingMethods(), nil)
        }
        else {
            completion(internationalShippingMethods(), nil)
        }
    }
    
    func californiaShippingMethods() -> [Any] {
        let upsGround = PKShippingMethod()
        upsGround.amount = NSDecimalNumber(string: "0.00")
        upsGround.label = "UPS Ground"
        upsGround.detail = "Arrives in 3-5 days"
        upsGround.identifier = "ups_ground"
        let fedex = PKShippingMethod()
        fedex.amount = NSDecimalNumber(string: "5.99")
        fedex.label = "FedEx"
        fedex.detail = "Arrives tomorrow"
        fedex.identifier = "fedex"
        return [upsGround, fedex]
    }
    
    func internationalShippingMethods() -> [Any] {
        let upsWorldwide = PKShippingMethod()
        upsWorldwide.amount = NSDecimalNumber(string: "10.99")
        upsWorldwide.label = "UPS Worldwide Express"
        upsWorldwide.detail = "Arrives in 1-3 days"
        upsWorldwide.identifier = "ups_worldwide"
        return californiaShippingMethods() + [upsWorldwide]
    }
}
