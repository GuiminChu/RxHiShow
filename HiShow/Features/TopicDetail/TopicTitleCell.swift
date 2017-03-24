//
//  TopicTitleCell.swift
//  HiShow
//
//  Created by Chu Guimin on 17/3/9.
//  Copyright © 2017年 cgm. All rights reserved.
//

import UIKit

class TopicTitleCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var createdLabel: UILabel!
    
    func configure(topicInfo: Topic) {
        nameLabel.text = topicInfo.author.name
        titleLabel.text = topicInfo.title
        createdLabel.text = topicInfo.created
        
        if let urlString = topicInfo.author.avatar, let url = URL(string: urlString) {
            avatarImageView.navi_setAvatar(RoundAvatar(avatarURL: url, avatarStyle: picoAvatarStyle), withFadeTransitionDuration: 0.25)
        }
    }
}
