//
//  SideMenuCell.swift
//  TenderWatch
//
//  Created by devloper65 on 6/22/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit

class SideMenuCell: UITableViewCell {
    
    @IBOutlet var imgIcon: UIImageView!
    @IBOutlet var lblMenu: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        self.imgIcon.image = nil
        self.lblMenu.text = ""
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
