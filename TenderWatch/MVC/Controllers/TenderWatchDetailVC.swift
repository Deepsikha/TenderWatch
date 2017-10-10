//
//  TenderWatchDetailVC.swift
//  TenderWatch
//
//  Created by devloper65 on 7/17/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage
import ObjectMapper

class TenderWatchDetailVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var imgTenderPhoto: UIImageView!
    @IBOutlet weak var lblTenderName: UILabel!
    @IBOutlet weak var lblCountry: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblDay: UILabel!
    @IBOutlet weak var txtDesc: UITextView!
    @IBOutlet weak var tblTenderContactDetail: UITableView!
    @IBOutlet weak var btnClientDetail: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnInterested: UIButton!
    
    @IBOutlet var vwImage: UIView!
    @IBOutlet var ScrollView: UIScrollView!
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var vwClientDetail: UIView!
    @IBOutlet weak var imgIsFollow: UIImageView!
    
    @IBOutlet weak var txtVwDescHeight: NSLayoutConstraint!
    @IBOutlet weak var tblTenderContactHeight: NSLayoutConstraint!
    @IBOutlet weak var vwHeight: NSLayoutConstraint!
    
    var cView: UIView!
    var tenderDetail: TenderDetail!
    var transperentView = UIView()
    static var id:String!
    var dic: [String: String] = [:]
    var scrollViewHeight:CGFloat = 0.0
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollViewHeight = vwHeight.constant
        self.btnDelete.layer.cornerRadius = 8
        self.btnInterested.layer.cornerRadius = 8
        
        self.imgIsFollow.layer.cornerRadius = 8
        self.vwClientDetail.layer.cornerRadius = 8
        self.vwClientDetail.layer.borderWidth = 1
        self.vwClientDetail.layer.borderColor  = UIColor.white.cgColor
        if appDelegate.isClient! {
            self.btnInterested.setTitle("Amend", for: .normal)
            self.btnInterested.layer.backgroundColor = UIColor.gray.cgColor
        } else {
            self.btnInterested.setTitle("Interested", for: .normal)
            self.btnInterested.layer.backgroundColor = UIColor(red: 145/255, green: 216/255, blue: 79/255, alpha: 1.0).cgColor
            
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.generateSubView(sender:)))
        tap.cancelsTouchesInView = false
        self.imgTenderPhoto.addGestureRecognizer(tap)
        
        self.tblTenderContactDetail.delegate = self
        self.tblTenderContactDetail.dataSource = self
        
        self.tblTenderContactDetail.estimatedRowHeight = 100
//        self.tblTenderContactDetail.rowHeight = UITableViewAutomaticDimension
        
        self.tblTenderContactDetail.register(UINib(nibName: "ClientDetailCell", bundle: nil), forCellReuseIdentifier: "ClientDetailCell")
        
        imageView = UIImageView(image: UIImage(named: "avtar"))
        imageView.sizeToFit()
        
        ScrollView = UIScrollView(frame: self.view.frame)
        ScrollView.backgroundColor = UIColor.black
        ScrollView.contentSize = imageView.bounds.size
        ScrollView.autoresizingMask = UIViewAutoresizing.flexibleWidth
        ScrollView.autoresizingMask = UIViewAutoresizing.flexibleHeight
        ScrollView.contentOffset = CGPoint(x: 0, y: 0)
        ScrollView.delegate = self
        ScrollView.minimumZoomScale = 0.1
        ScrollView.maximumZoomScale = 2.0
        ScrollView.zoomScale = 1.0
        ScrollView.showsVerticalScrollIndicator = false
        ScrollView.showsHorizontalScrollIndicator = false
        ScrollView.addSubview(imageView)
        vwImage.addSubview(ScrollView)
        let btn = UIButton(frame: CGRect(x: 10, y: 30, width: 30, height: 30))
        btn.setImage(UIImage(named: "cancel-menu"), for: .normal)
        btn.layer.backgroundColor = UIColor.clear.cgColor
        btn.addTarget(self, action: #selector(self.tapHandler(sender:)), for: .touchDown)
        vwImage.addSubview(btn)
        
        setZoomScale()
        setupGestureRecognizer()
        getDetail()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        self.txtVwDescHeight.constant = self.txtDesc.contentSize.height
        self.tblTenderContactHeight.constant = self.tblTenderContactDetail.contentSize.height
        self.view.layoutIfNeeded()
        
        self.vwHeight.constant = scrollViewHeight + (self.txtDesc.contentSize.height) + (self.tblTenderContactHeight.constant)
        self.transperentView.frame = self.view.frame

        self.vwClientDetail.frame = CGRect(x: self.transperentView.center.x - (self.vwClientDetail.frame.width / 2), y: self.transperentView.center.y - 150, width:self.vwClientDetail.frame.width, height: self.vwClientDetail.frame.height)
        
        self.vwImage.frame = self.view.frame
        self.ScrollView.frame = self.vwImage.frame
        
        setZoomScale()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if appDelegate.isClient! {
            self.btnClientDetail.isHidden = true
        } else {
            self.btnClientDetail.isHidden = false
        }
        self.navigationController?.isNavigationBarHidden = true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: ScrollView Delegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let imageViewSize = imageView.frame.size
        let scrollViewSize = ScrollView.frame.size
        
        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
//        scrollView.contentSize = imageViewSize
        
        ScrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
    }
    
    //MARK:- Table Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dic.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ClientDetailCell = tableView.dequeueReusableCell(withIdentifier: "ClientDetailCell", for: indexPath) as! ClientDetailCell
        cell.lblKey.text = (dic as NSDictionary).allKeys[indexPath.row] as? String
        cell.lblValue.text = (dic as NSDictionary).value(forKey: cell.lblKey.text!) as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    //MARK:- IBActions
    @IBAction func handleBtnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func handleBtnClientDetail(_ sender: Any) {
        if appDelegate.isClient! {
        
        } else {
                let vc = UserDetailVC()
                vc.id = self.tenderDetail.tenderUploader?._id
                self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func handleBtnDelete(_ sender: Any) {
        let msg: String!
        if (appDelegate.isClient)! {
            msg = "Tender will be completely removed from TenderWatch?"
        } else {
            msg = "Are you sure you want to remove this Tender completely from your Account?"
        }
        
        let alert = UIAlertController(title: "TenderWatch", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.view.backgroundColor = UIColor.white
        alert.view.layer.cornerRadius = 10.0
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler:{ action in
        }))
        alert.addAction(UIAlertAction(title: "Remove", style: .cancel, handler:{ action in
            if isNetworkReachable() {
                self.stopActivityIndicator()
                Alamofire.request(DELETE_TENDER+self.tenderDetail.id! , method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: ["Authorization":"Bearer \(UserManager.shared.user!.authenticationToken!)"]).responseJSON { (resp) in
                    if(resp.response?.statusCode != nil) {
                        if !(resp.response?.statusCode == 200) {
                            MessageManager.showAlert(nil, "can't Remove tender")
                        } else {
                            TenderWatchVC.id = TenderWatchDetailVC.id
                            self.navigationController?.popViewController(animated: true)
                        }
                        self.stopActivityIndicator()
                    }
                }
            } else {
                MessageManager.showAlert(nil, "No Internet")
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func handleBtnInterested(_ sender: Any) {
        
        if (appDelegate.isClient!) {
            UploadTenderVC.isUpdate = true
            UploadTenderVC.id = TenderWatchDetailVC.id
            
            self.navigationController?.pushViewController(UploadTenderVC(), animated: true)
            
        } else {
            Alamofire.request(INTERESTED+self.tenderDetail.id!, method: .put, parameters: [:], encoding: JSONEncoding.default, headers: ["Authorization":"Bearer \(UserManager.shared.user!.authenticationToken!)"]).responseJSON(completionHandler: { (resp) in
                if resp.response?.statusCode != nil {
                    if (resp.response?.statusCode == 304) {
                        MessageManager.showAlert(nil, "Already interested ")
                    } else {
                        MessageManager.showAlert(nil, "We have notified the Client about your interest in this Tender./nTo pursue please continue with the process as specified in the Tender Details")
                        self.btnInterested.isEnabled = false
                        self.btnInterested.backgroundColor = UIColor(red: 145/255, green: 216/255, blue: 79/255, alpha: 0.7)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "interested"), object: nil, userInfo: ["id":"\(self.tenderDetail.id!)","tag":"1"])
                        
                        
                        //fire notification
                        //work remaining based on client req.
                    }
                }
            })
            
        }
    }
    
    //MARK:- Custom Methods
    func getDetail() {
        if isNetworkReachable() {
            self.startActivityIndicator()
            Alamofire.request(TENDER_DETAIL+"\(TenderWatchDetailVC.id!)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(UserManager.shared.user!.authenticationToken!)"]).responseJSON(completionHandler: { (resp) in
                if(resp.result.value != nil) {
                    if ((resp.result.value as! NSDictionary).allKeys.contains(where: { (a) -> Bool in
                        if (a as! String) == "error" {
                            return true
                        } else {
                            return false
                        }
                    })) {
                        let err = (resp.result.value as! NSObject).value(forKey: "error")
                        MessageManager.showAlert(nil, "\(String(describing: err))")
                    } else {
                        let data = (resp.result.value as! NSObject)
                        self.tenderDetail = Mapper<TenderDetail>().map(JSONObject: data)
                        if (TenderWatchVC.isAmended) {
                            MessageManager.showAlert(nil, "Tender has been amended by Client")
                            TenderWatchVC.isAmended = false
                        }
                        
                        if self.tenderDetail.interested!.contains(USER!._id!) {
                            self.btnInterested.backgroundColor = UIColor(red: 145/255, green: 216/255, blue: 79/255, alpha: 0.7)
                            self.btnInterested.isEnabled = false
                        }
                        
                        self.lblTenderName.text = self.tenderDetail.tenderName!
                        self.lblCountry.text = self.tenderDetail.country!.countryName!
                        
                        self.lblCategory.text = self.tenderDetail.category!.categoryName!
                    
                        if !(self.tenderDetail.email!.isEmpty)  {
                            self.dic["Email:"] = self.tenderDetail.email!
                        }
                        
                        if !(self.tenderDetail.contactNo!.isEmpty)  {
                            self.dic["Mobile No:"] = self.tenderDetail.contactNo!
                        }
                        
                        if !(self.tenderDetail.landlineNo!.isEmpty)  {
                            self.dic["LandLine No:"] = self.tenderDetail.landlineNo!
                        }
                        
                        if !(self.tenderDetail.address!.isEmpty)  {
                            self.dic["Address:"] = self.tenderDetail.address!
                        }
                        
                        if (self.tenderDetail.isFollowTender)! {
                            self.dic["Follow Tender Process"] = ""
                        }
                        
                        let date = data.value(forKey: "expiryDate")! as? String
                        let components = Date().getDifferenceBtnCurrentDate(date: (date?.substring(to: (date!.index((date!.startIndex), offsetBy: 10))))!)
                        
                        self.lblDay.text = (components.day == 0) ? "Last Day" : (components.day == 1) ? "\(components.day!) day" : "\(components.day!) days"
                        
                        self.txtDesc.text = self.tenderDetail.desc!
                        self.imgTenderPhoto.sd_setImage(with: URL(string: self.tenderDetail.tenderPhoto!), placeholderImage: UIImage(named: "avtar"), options: SDWebImageOptions.progressiveDownload, completed: { (image, error, memory, url) in
                            if image != nil {
                                self.imageView.image = image!
                            } else {
                                self.imageView.image = UIImage(named: "avtar")
                            }
                            self.ScrollView.contentSize = self.imageView.frame.size
                        })
                    }
                    self.tblTenderContactDetail.reloadData()
                    self.stopActivityIndicator()
                }
            })
        } else {
            MessageManager.showAlert(nil, "No Internet")
        }
    }
    
    func generateSubView(sender: NSObject) {
        
        let tapBtn = UITapGestureRecognizer(target: self, action: #selector(self.tapHandler(sender:)))
        tapBtn.cancelsTouchesInView = false
        
        let tap = UISwipeGestureRecognizer(target: self, action: #selector(self.tapHandler(sender:)))
        tap.direction = UISwipeGestureRecognizerDirection.right
        tap.cancelsTouchesInView = false

        if sender == self.btnClientDetail {
            if self.tenderDetail.isFollowTender! {
                self.transperentView = UIView(frame: self.view.frame)
                self.transperentView.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.25)
                self.transperentView.addSubview(self.vwClientDetail)
                if !self.view.subviews.contains(self.transperentView) {
                    self.view.addSubview(self.transperentView)
                }
                self.transperentView.addGestureRecognizer(tapBtn)
            } else {
                
            }
        } else {
            if !self.view.subviews.contains(self.vwImage) {
                self.view.addSubview(self.vwImage)
            }
            ScrollView.addGestureRecognizer(tap)
        }
    }
    
    func tapHandler(sender: NSObject) {
        if self.view.subviews.contains(self.transperentView) {
            self.transperentView.removeFromSuperview()
        }
        if self.view.subviews.contains(self.vwImage) {
            self.vwImage.removeFromSuperview()
        }
    }
    
    func setZoomScale() {
        let imageViewSize = imageView.bounds.size
        let ScrollViewSize = ScrollView.bounds.size
        let widthScale = ScrollViewSize.width / imageViewSize.width
        let heightScale = ScrollViewSize.height / imageViewSize.height
        
        ScrollView.minimumZoomScale = min(widthScale,heightScale)
        ScrollView.zoomScale = 1.0
    }
    
    func setupGestureRecognizer() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        ScrollView.addGestureRecognizer(doubleTap)
    }
    
    func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        if (ScrollView.zoomScale > ScrollView.minimumZoomScale) {
            ScrollView.setZoomScale(ScrollView.minimumZoomScale, animated: true)
            
        } else {
            ScrollView.setZoomScale(ScrollView.maximumZoomScale, animated: true)
        }
    }
    
}
