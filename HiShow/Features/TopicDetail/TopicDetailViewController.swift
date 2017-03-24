//
//  TopicDetailViewController.swift
//  HishowZone
//
//  Created by Chu Guimin on 16/9/12.
//  Copyright © 2016年 Chu Guimin. All rights reserved.
//

import UIKit

class TopicDetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var topic: Topic?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        
        // tableViewCell 自动计算高度
        tableView.estimatedRowHeight = 88.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
//        tableView.register(TopicContentCell.self)
        tableView.register(TopicTitleCell.self)
        tableView.register(TopicDetailCell.self)

        NotificationCenter.default.addObserver(self, selector: #selector(imagePressed(_:)), name: HiShowConfig.NotificationName.coreTextImagePressedNotification, object: nil)
    }
    
    func imagePressed(_ notification: Notification) {
        let userInfo = notification.userInfo
        
        guard let imageData =  userInfo?["imageData"] as? CoreTextImageData else {
            return
        }
        
        
            
//            guard imageView.image != R.Image.ImagePlaceholder else {
//                return
//            }
            
            
        guard let displayView = userInfo?["displayView"] as? CTDisplayView else {
            return
        }
        
        // 翻转坐标系，因为 imageData 中的坐标是 CoreText 的坐标系
        let imageRect = imageData.imagePosition
        var imagePosition = imageRect.origin
        imagePosition.y = displayView.bounds.size.height - imageRect.origin.y - imageRect.size.height
        let rect = CGRect(x: imagePosition.x, y: imagePosition.y, width: imageRect.size.width, height: imageRect.size.height)
        
        var imageInfo = ImageInfo()
        imageInfo.image = imageData.image
        // imageInfo.originalData = imageView.originalData
        imageInfo.referenceRect = rect
        imageInfo.referenceView = displayView
        let imageVC = ImageViewingController(imageInfo: imageInfo)
        imageVC.presented(by: self)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: HiShowConfig.NotificationName.coreTextImagePressedNotification, object: nil)
    }
}

extension TopicDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: TopicTitleCell.reuseIdentifier, for: indexPath) as! TopicTitleCell
            cell.configure(topicInfo: topic!)
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: TopicDetailCell.reuseIdentifier, for: indexPath) as! TopicDetailCell
            cell.configure(topic: topic!)
            return cell
        } else {
            return UITableViewCell()
        }
    }
}
