//
//  UserInfoCell.swift
//  HishowZone
//
//  Created by Chu Guimin on 16/9/10.
//  Copyright © 2016年 Chu Guimin. All rights reserved.
//

import UIKit

class UserInfoCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locNameLabel: UILabel!
    @IBOutlet weak var signatureLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(_ userInfo: UserInfo?) {
        
        if let user = userInfo {
            nameLabel.text = user.name
            locNameLabel.text = user.locName
            signatureLabel.text = user.signature
        }
    }
}
