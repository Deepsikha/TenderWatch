//
//  RegisterCountryCell.swift
//  TenderWatch
//
//  Created by Developer88 on 6/22/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit

class RegisterCountryCell: UITableViewCell {

    
    @IBOutlet weak var countryName: MarqueeLabel!
    @IBOutlet var imgTick: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
