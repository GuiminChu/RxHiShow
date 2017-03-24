//
//  TopicDetailCell.swift
//  HiShow
//
//  Created by Chu Guimin on 17/2/28.
//  Copyright © 2017年 cgm. All rights reserved.
//

import UIKit

class TopicDetailCell: UITableViewCell {
    
    @IBOutlet weak var displayView: CTDisplayView!
    @IBOutlet weak var displayViewHeight: NSLayoutConstraint!
    @IBOutlet weak var displayViewWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        displayViewWidth.constant = kScreenWidth - 30.0
    }

    func configure(topic: Topic) {
        
        var config = CTFrameParserConfig()
        config.width = displayViewWidth.constant
        
        let data = CTFrameParser.parseTopicInfo(topic: topic, config: config)
                
        displayViewHeight.constant = data.height
        displayView.data = data
    }
}
