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
    @IBOutlet weak var lblNotify: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.lblNotify.layer.cornerRadius = self.lblNotify.layer.frame.width / 2
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
