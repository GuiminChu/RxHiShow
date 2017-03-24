//
//  TopicContentCell.swift
//  HishowZone
//
//  Created by Chu Guimin on 16/9/12.
//  Copyright © 2016年 Chu Guimin. All rights reserved.

//  http://stackoverflow.com/questions/24029163/finding-index-of-character-in-swift-string
//  http://stackoverflow.com/questions/40413218/swift-find-all-occurrences-of-a-substring

import UIKit
import Kingfisher

class TopicContentCell: UITableViewCell {

    @IBOutlet weak var contentLabel: UILabel!
    
    func configure(topic: Topic?) {
        
        if let content = topic?.content {
            print(content)
            
            let tuples = handleContentString(content)
            
            print(tuples)
            
            
            let stringOnly = tuples.0

            let attributedText = NSMutableAttributedString(string: stringOnly)
            
            // insertIndex 记录需要插入图片的原始位置，插入一张图片后(图片占一个字符)原始位置向右偏移一位才是真实位置
            for (offset, insertIndex) in tuples.1.enumerated() {
                
                // 图片附件
                let imageAttachment = NSTextAttachment()
                let image = UIImage(named: "Image")
                imageAttachment.image = image
                
                let photoInfo = topic?.photos[offset]
                
                
                let imageWidth = kScreenWidth - 16
                let imageHeight = CGFloat(photoInfo!.size.height) / CGFloat(photoInfo!.size.width) * imageWidth
                imageAttachment.bounds = CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)
                
                KingfisherManager.shared.retrieveImage(with: URL(string: (topic?.photos[offset].alt)!)!, options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, imageURL) in
                    
                    imageAttachment.image = image
                    print(cacheType)
                    
                    self.setNeedsDisplay()
                })
                
                
            
                attributedText.insert(NSAttributedString(attachment: imageAttachment), at: insertIndex + offset)
            }
            
            contentLabel.attributedText = attributedText
        }
    }
    
    func handleContentString(_ str: String) -> (String, [Int]) {
        
        var indexArray = [Int]()
        guard let _ = str.range(of: "<图片") else {
            return (str, indexArray)
        }
        
        // 删除文本中的换行符"\r" (注：\r不占用字符)
        var result = str.replacingOccurrences(of: "\r", with: "")
        
        while let range = result.range(of: "<图片") {
            indexArray.append(result.characters.distance(from: result.startIndex, to: range.lowerBound))
    
            // 从 "<图片1" 后面的字符串中检索 ">"
            let r = Range(range.lowerBound..<result.endIndex)
            // <图片1> 右侧 ">" 的 Range
            let rightRange = result.range(of: ">", options: NSString.CompareOptions.caseInsensitive, range: r)
            // <图片1> 的 Range
            let picRange = Range(range.lowerBound..<rightRange!.upperBound)
            result = result.replacingCharacters(in: picRange, with: "\n\n")
        }
        
        return (result, indexArray)
    }
}
