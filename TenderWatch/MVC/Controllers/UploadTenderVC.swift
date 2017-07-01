//
//  UploadTenderVC.swift
//  TenderWatch
//
//  Created by Developer88 on 6/28/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit
import Alamofire

class UploadTenderVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate {

    @IBOutlet weak var opnDrwr: UIButton!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var txfTenderTitle: UITextField!
    
    @IBOutlet weak var lblDropdown: UILabel!

    @IBOutlet weak var lblDropdownCat: UILabel!
    
    @IBOutlet weak var tenderDetail: UITextView!
    
    @IBOutlet weak var btnSelectCountry: UIButton!

    @IBOutlet weak var btnSelectCategory: UIButton!

    @IBOutlet weak var btnContact: UIButton!
    
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var vwSelectCountry: UIView!
    
    @IBOutlet weak var vwSelectCategory: UIView!
    @IBOutlet weak var vwMain: UIView!
    
    @IBOutlet weak var tempView: UIView!
    
    @IBOutlet var vwContactPopup: UIView!
    @IBOutlet var tblOptions: UITableView!
    
    var arrDropDown = [String]()
    var tender = [Tender]()

    var isCountry = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerNib()
    }

    override func viewWillAppear(_ animated: Bool) {
         self.navigationController?.isNavigationBarHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func registerNib(){
        
        self.vwSelectCountry.layer.cornerRadius = 5
        self.vwSelectCategory.layer.cornerRadius = 5
        self.vwContactPopup.layer.cornerRadius = 5
        self.txfTenderTitle.layer.cornerRadius = 5
        self.btnContact.layer.cornerRadius = 5
        self.btnSubmit.cornerRedius()
        
        // control design formation
        self.tenderDetail.layer.cornerRadius = 5
        self.tenderDetail.layer.borderColor = UIColor.lightGray.cgColor
        self.tenderDetail.layer.borderWidth = 1
        self.txfTenderTitle.layer.borderColor = UIColor.lightGray.cgColor
        self.txfTenderTitle.layer.borderWidth = 1
        
    
        self.tblOptions.dataSource = self
        self.tblOptions.delegate = self
        tblOptions.register(UINib(nibName: "MappingCell",bundle: nil), forCellReuseIdentifier: "Dropdowncell")
        
        let tapHappen = UITapGestureRecognizer(target: self, action: #selector(hideDropDown))
        self.tempView.addGestureRecognizer(tapHappen)
    }
    
    func hideDropDown(){
        if (self.tempView.subviews.contains(self.tblOptions)) {
            self.tblOptions.removeFromSuperview()
            lblDropdown.text = "▼"
            lblDropdownCat.text = "▼"
            removeTempView()

            
        }
    }
    // MARK:- Table view
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrDropDown.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Dropdowncell") as! MappingCell

        cell.lblCategory.text = arrDropDown[indexPath.row]
        
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (isCountry) {
            btnSelectCountry.titleLabel?.text = arrDropDown[indexPath.row]
            lblDropdown.text = "▼"
            removeTempView()

        }else{
            btnSelectCategory.titleLabel?.text = arrDropDown[indexPath.row]
            lblDropdownCat.text = "▼"
            removeTempView()
        }
        self.tblOptions.removeFromSuperview()
    }
    // MARK:- IBActions
    
    @IBAction func handleOpenDrwr(_ sender: Any) {
        appDelegate.drawerController.toggleDrawerSide(.left, animated: true, completion: nil)
    }
    
    @IBAction func btnSelectCountry(_ sender: Any) {
        self.isCountry = true
        addTempView();
        if (self.vwMain.subviews.contains(self.tblOptions)) {
            self.tblOptions.removeFromSuperview()
        }
        lblDropdown.text = "▲"
        self.tblOptions.frame = CGRect(x: self.vwSelectCountry.frame.origin.x, y: self.vwSelectCountry.frame.origin.y + 40, width: self.vwSelectCountry.frame.width, height: 200)
        self.tempView.addSubview(self.tblOptions)
        arrDropDown = ["Austrailia","brazil","india","Usa"]
        tblOptions.reloadData()
    }
    
    @IBAction func btnSelectCategory(_ sender: Any) {
        self.isCountry = false
        addTempView();
        lblDropdownCat.text = "▲"
        if (self.vwMain.subviews.contains(self.tblOptions)) {
            self.tblOptions.removeFromSuperview()
        }
        self.tblOptions.frame = CGRect(x: self.vwSelectCategory.frame.origin.x, y: self.vwSelectCategory.frame.origin.y + 40, width: self.vwSelectCountry.frame.width, height: 200)
        self.tempView.addSubview(self.tblOptions)
        arrDropDown = ["dev","web","design","testing"]
        tblOptions.reloadData()
    }
    
    @IBAction func btnShowContactPopup(_ sender: Any) {
        self.vwContactPopup.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        self.view.addSubview(vwContactPopup)
    }
    
    @IBAction func btnDoneHidePopup(_ sender: Any) {
        self.vwContactPopup.removeFromSuperview()
    }
    @IBAction func sbmt(_ sender: Any) {
        APIManager.shared.requestForPOST(url: "api/tender", isTokenEmbeded: true, params: [:], successHandler: { (true, resp) in
        print(resp)
     }) { (error) in
        print(error)
        }
    }

    // tap gesture
    func addTempView(){
        self.tempView.isHidden = false
    }
    
    func removeTempView(){
        self.tempView.isHidden = true
    }
}
