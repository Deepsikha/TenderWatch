//
//  NotificationCell.swift
//  TenderWatch
//
//  Created by devloper65 on 8/11/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {

    @IBOutlet weak var imgSender: UIImageView!
    @IBOutlet weak var lblContent: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var imgIdentity: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imgSender.layer.cornerRadius = self.imgSender.frame.width / 2

        self.imgIdentity.layer.cornerRadius = self.imgIdentity.frame.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
