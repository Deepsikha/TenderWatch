//
//  MappingCell.swift
//  TenderWatch
//
//  Created by devloper65 on 6/29/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit

class MappingCell: UITableViewCell {
    
    @IBOutlet weak var lblCategory: MarqueeLabel!
    @IBOutlet weak var imgTick: UIImageView!
    @IBOutlet weak var imgString: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
