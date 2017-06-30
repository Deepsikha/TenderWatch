//
//  UploadTenderVC.swift
//  TenderWatch
//
//  Created by Developer88 on 6/28/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit

class UploadTenderVC: UIViewController {

    @IBOutlet weak var opnDrwr: UIButton!
    @IBOutlet weak var lblName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
            self.navigationController?.isNavigationBarHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func handleOpenDrwr(_ sender: Any) {
        appDelegate.drawerController.toggleDrawerSide(.left, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
