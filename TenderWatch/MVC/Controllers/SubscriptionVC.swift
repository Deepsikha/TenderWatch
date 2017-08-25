//
//  SubscriptionVC.swift
//  TenderWatch
//
//  Created by devloper65 on 6/26/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit

class SubscriptionVC: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var tblSubscription: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblSubscription.delegate = self
        self.tblSubscription.dataSource = self
        
        self.tblSubscription.register(UINib(nibName: "SubscriptionCell", bundle: nil), forCellReuseIdentifier: "SubscriptionCell")
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- TableView Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubscriptionCell", for: indexPath) as! SubscriptionCell
        return cell
    }
    
    //MARK:- IBAction
    @IBAction func handleBtnBack(_ sender: Any) {
        appDelegate.drawerController.toggleDrawerSide(.left, animated: true, completion: nil)
    }
//    Subscription detail functionality
//    ========================
//    -     When a contractor sign up fora first time, he will have to choose the initial subscription plan
//    -     Subscription plans will be 1. 1 month free trial
//    2. Monthly subscription
//    3. Yearly subscription
//    -    Before he goes to his home screen, he need to choose any of these plan
//    -    For one month free trial he is allowed to choose only one country and one category.
//    -    During free trial if someone tries to choose more than one country, there should be an alert that “During free trail you can choose only one country”- same for category
//    -     If the subscription is paid before 7 days then, the app should not display an alert
//    -    Notification when only 7 days remaining
//    -    Again one more notification if only 2 days remaining - “Your free trail expires in 2 days”
//    -    15 $ / month
//    -     120 $ / Year
//    -     Add 120 $ every time whenever a country or category increases
//
//    [8:01]
//    You need to check 3-4 apps for the subscription screen design and payment gateway screen
//    Subscription key in user model so that we can verify user's subscription and base on that we can select country and category
    
//    intefration of payment gateway on both side and UI Design at iOS side
    
//    [8:02]
//    On 23/08/17, at 8:00 PM, Imtiaz Lalji wrote:
//    > What happens when Free Trial Finishes? Or Subscription finishes?
//    
//    That we have not discussed yet
}
