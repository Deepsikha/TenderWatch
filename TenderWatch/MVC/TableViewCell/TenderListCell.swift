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
    
    @IBOutlet weak var imgIndocator: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var exp_day: UILabel!
    
    @IBOutlet weak var vwDelete: UIView!
    @IBOutlet weak var lblDelete: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.imgIndocator.layer.borderColor = UIColor.white.cgColor
        self.imgIndocator.layer.borderWidth = 1
    }
    
    override func layoutSubviews() {
        self.imgProfile.layer.masksToBounds = true;
        self.imgProfile.layer.cornerRadius = self.imgProfile.frame.width/2.0
        
        self.imgIndocator.layer.masksToBounds = true
        self.imgIndocator.layer.cornerRadius = self.imgIndocator.frame.width / 2

    }
    
    override func prepareForReuse() {
        self.imgProfile.layer.borderColor = UIColor.clear.cgColor
        self.imgProfile.layer.borderWidth = 0        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
