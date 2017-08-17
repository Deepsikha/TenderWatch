//
//  UserDetailVC.swift
//  TenderWatch
//
//  Created by devloper65 on 8/10/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit

class UserDetailVC: UIViewController {

    var detail: User!
    static var rate: Int!
    
    @IBOutlet weak var vwStack: RatingControl!
    @IBOutlet weak var btnCancel: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        if !(appDelegate.isClient!) {
            self.vwStack.isHidden = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func handleBtnCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
