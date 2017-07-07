//
//  TenderListCell.swift
//  TenderWatch
//
//  Created by devloper65 on 6/21/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit

class TenderListCell: UITableViewCell {
    
    @IBOutlet var imgProfile: UIImageView!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblCountry: UILabel!
    @IBOutlet var lblTender: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    override func layoutSubviews() {
        self.imgProfile.layer.masksToBounds = true;
        self.imgProfile.layer.cornerRadius = self.imgProfile.frame.width/2.0
        self.imgProfile.layer.borderWidth = 1.0
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
