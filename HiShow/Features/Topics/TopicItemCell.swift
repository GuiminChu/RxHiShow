//
//  TopicItemCell.swift
//  HishowZone
//
//  Created by Chu Guimin on 16/9/6.
//  Copyright © 2016年 Chu Guimin. All rights reserved.
//

import UIKit
import RxSwift
import Kingfisher

final class TopicItemCell: UITableViewCell {
    
    // MARK: - Properties
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var topicImageView: UIImageView!
    @IBOutlet weak var likeCountLabel: UILabel!
    

    let gestureRecognizer = UITapGestureRecognizer()
    
    var disposeBag = DisposeBag()
    
    // MARK: - View Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        avatarImageView.addGestureRecognizer(gestureRecognizer)
        
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        topicImageView.image = nil
        avatarImageView.image = nil
    }
    
    func configure(_ topicInfo: Topic) {
        
        nameLabel.text = topicInfo.author.name
        titleLabel.text = topicInfo.title
        likeCountLabel.text = "\(topicInfo.likeCount!)"
        
        if let photoAlt = topicInfo.photos.first?.alt, let url = URL(string: photoAlt) {
            topicImageView.kf.setImage(with: url, options: [KingfisherOptionsInfoItem.transition(ImageTransition.fade(0.25))])
        }
        
        if let urlString = topicInfo.author.avatar, let url = URL(string: urlString) {
            avatarImageView.navi_setAvatar(RoundAvatar(avatarURL: url, avatarStyle: picoAvatarStyle), withFadeTransitionDuration: 0.25)
        }
    }
}
