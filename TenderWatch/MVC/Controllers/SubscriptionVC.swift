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
    @IBAction func handleBtnBack(_ sender: Any) {
        appDelegate.drawerController.toggleDrawerSide(.left, animated: true, completion: nil)
    }
    
    //MARK:- Table Delegate
    
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
}
