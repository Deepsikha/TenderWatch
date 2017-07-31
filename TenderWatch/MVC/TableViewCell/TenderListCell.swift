//
//  TenderListCell.swift
//  TenderWatch
//
//  Created by devloper65 on 7/7/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit

class TenderListCell: UITableViewCell {

    @IBOutlet var imgProfile: UIImageView!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblCountry: UILabel!
    @IBOutlet var lblTender: UILabel!
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var exp_day: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        self.imgProfile.layer.masksToBounds = true;
        self.imgProfile.layer.cornerRadius = self.imgProfile.frame.width/2.0
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
