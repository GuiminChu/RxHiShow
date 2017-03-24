//
//  CTFrameParser.swift
//  HiShow
//
//  Created by Chu Guimin on 17/3/8.
//  Copyright © 2017年 cgm. All rights reserved.
//

import UIKit

class CTFrameParser: NSObject {
    
    /// 解析模板文件
    class func parseTopicInfo(topic: Topic, config: CTFrameParserConfig) -> CoreTextData {
        var imageArray = [CoreTextImageData]()
//        var linkArray  = [CoreTextLinkData]()
        
        let content = self.loadTopicInfo(topic: topic, config: config, imageArray: &imageArray)
        
        let coreTextData = self.parse(content: content, config: config)
        
        coreTextData.imageArray = imageArray
//        coreTextData.linkArray = linkArray
        
        return coreTextData
    }
    
    private static func parseTopicContentString(_ str: String) -> (String, [Int]) {
        
        var indexArray = [Int]()
        guard let _ = str.range(of: "<图片") else {
            return (str, indexArray)
        }
        
        // 删除文本中的 emoji
        let resultWithoutEmoji = removeEmoji(string: str)
        
        // 删除文本中的换行符"\r" (注：\r不占用字符)
        var result = resultWithoutEmoji.replacingOccurrences(of: "\r", with: "")
        
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
    
    /// 删除字符串中的 emoji 表情
    ///
    /// - Parameter string:  "emoji 😀"
    /// - Returns:  "emoji"
    private static func removeEmoji(string: String) -> String {

        
        let emojiPattern1 = "\\U00010000-\\U0010FFFF"   // Emoticons
        let emojiPattern2 = "\\u2100-\\u27BF"           // Misc symbols and Dingbats
        let emojiPattern3 = "\\u200D\\uFE0f"            // Special Characters
        let emojiPattern4 = "\\U0001F595-\\U0001F596"   // (🖕..🖖)
        
        let pattern = "[\(emojiPattern1)\(emojiPattern2)\(emojiPattern3)\(emojiPattern4)]"

        // let emojiVariants = "\(EmojiData.EmojiPatterns.joined(separator: ""))\\uFE0F)"
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let replaced = regex.stringByReplacingMatches(in: string, options: [], range: NSRange(0..<string.utf16.count), withTemplate: "")
        
        return replaced
    }
    
    /// 根据话题信息生成 NSAttributedString 实例
    ///
    /// - Parameters:
    ///   - topic: 话题
    ///   - config: 配置
    ///   - imageArray: 图片数组
    /// - Returns: NSAttributedString实例
    private class func loadTopicInfo(topic: Topic, config: CTFrameParserConfig, imageArray: inout [CoreTextImageData]) -> NSAttributedString {
        
        let result = NSMutableAttributedString()
        
        if let content = topic.content {
            
            // print(content)
            let tuples = parseTopicContentString(content)
            // print(tuples)
            
            // 处理文本
            let attributes = self.attributes(config: config)
            result.append(NSAttributedString(string: tuples.0, attributes: attributes))
            
            // 处理图片
            // insertIndex 记录需要插入图片的原始位置，插入一张图片后(图片占一个字符)原始位置向右偏移一位才是真实位置
            for (offset, insertIndex) in tuples.1.enumerated() {
                
                let photoInfo = topic.photos[offset]
                
                let imageData = CoreTextImageData()
                imageData.title = photoInfo.title
                imageData.imageUrl = photoInfo.alt
                imageData.imagePosition = CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)
                imageArray.append(imageData)
                
                let subStr = self.parseImageAttributedCotnent(photoInfo: photoInfo, config: config)
                result.insert(subStr, at: insertIndex + offset + 1)
            }
        }

        return result
    }
    
    
    /// 根据富文本生成 CoreTextData 实例
    ///
    /// - Parameters:
    ///   - content: 富文本
    ///   - config: 配置
    /// - Returns: 需要渲染的数据
    private static func parse(content: NSAttributedString, config: CTFrameParserConfig) -> CoreTextData {
        // 创建 CTFramesetter 实例
        let framesetter = CTFramesetterCreateWithAttributedString(content)
        
        // 获取要绘制的区域的高度
        let restrictSize = CGSize(width: config.width, height: CGFloat.greatestFiniteMagnitude)
        let coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), nil, restrictSize, nil)
        let textHeight = coreTextSize.height
        
        // 生成 CTFrame 实例
        let frame = self.creatFrame(framesetter: framesetter, config: config, height: textHeight)
        
        // 将生成的 CTFrame 实例和计算好的绘制高度保存到 CoreTextData 实例中
        let data = CoreTextData(ctFrame: frame, height: textHeight)
        
        // 返回 CoreTextData 实例
        return data
    }
    
    
    /// 创建矩形文字区域
    ///
    /// - Parameters:
    ///   - framesetter: framesetter
    ///   - config: 配置
    ///   - height: 高度
    /// - Returns: 矩形文字区域
    private class func creatFrame(framesetter: CTFramesetter, config: CTFrameParserConfig, height: CGFloat) -> CTFrame {
        let path = CGMutablePath()
        path.addRect(CGRect(x: 0, y: 0, width: config.width, height: height))
        
        return CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, nil)
    }
    
    /// 配置文字信息
    ///
    /// - Parameter config: 配置信息
    /// - Returns: 文字基本属性
    private class func attributes(config: CTFrameParserConfig) -> [String: Any] {
        // 字体大小
        let fontSize = config.fontSize
        let uiFont = UIFont.systemFont(ofSize: fontSize)
        let ctFont = CTFontCreateWithName(uiFont.fontName as CFString?, fontSize, nil)
        // 字体颜色
        let textColor = config.textColor
        
        // 行间距
        var lineSpacing = config.lineSpace
        
        let settings = [
            CTParagraphStyleSetting(spec: .lineSpacingAdjustment, valueSize: MemoryLayout<CGFloat>.size, value: &lineSpacing),
            CTParagraphStyleSetting(spec: .maximumLineSpacing, valueSize: MemoryLayout<CGFloat>.size, value: &lineSpacing),
            CTParagraphStyleSetting(spec: .minimumLineSpacing, valueSize: MemoryLayout<CGFloat>.size, value: &lineSpacing)
        ]
        let paragraphStyle = CTParagraphStyleCreate(settings, settings.count)
        
        // 封装
        let dict: [String: Any] = [
            NSForegroundColorAttributeName: textColor,
            NSFontAttributeName: ctFont,
            NSParagraphStyleAttributeName: paragraphStyle
        ]
        
        return dict
    }
    
    
    class PictureRunInfo {
        
        var ascender: CGFloat
        var descender: CGFloat
        var width: CGFloat
        
        init(ascender: CGFloat, descender: CGFloat, width: CGFloat) {
            self.ascender = ascender
            self.descender = descender
            self.width = width
        }
    }
    
    /// 从字典中解析图片富文本信息
    ///
    /// - Parameters:
    ///   - dict: 文字属性字典
    ///   - config: 配置信息
    /// - Returns: 图片富文本
    private class func parseImageAttributedCotnent(photoInfo: Photo, config: CTFrameParserConfig) -> NSAttributedString {
        
        let imageWidth = config.width
        let imageHeight = CGFloat(photoInfo.size.height) / CGFloat(photoInfo.size.width) * imageWidth
        
        let ascender = imageHeight
        let width = imageWidth
        let pic = PictureRunInfo(ascender: ascender, descender: 0.0, width: width)
        
        var callbacks = CTRunDelegateCallbacks(version: kCTRunDelegateVersion1, dealloc: { refCon in
            print("RunDelegate dealloc!")
        }, getAscent: { (refCon) -> CGFloat in
            let pictureRunInfo = unsafeBitCast(refCon, to: PictureRunInfo.self)
            return pictureRunInfo.ascender
        }, getDescent: { (refCon) -> CGFloat in
            return 0
        }, getWidth: { (refCon) -> CGFloat in
            let pictureRunInfo = unsafeBitCast(refCon, to: PictureRunInfo.self)
            return pictureRunInfo.width
        })
        
        
        let selfPtr = UnsafeMutableRawPointer(Unmanaged.passRetained(pic).toOpaque())
        
        // 创建 RunDelegate, 传入 imageCallback 中图片数据
        let runDelegate = CTRunDelegateCreate(&callbacks, selfPtr)
        
        
        let imageAttributedString = NSMutableAttributedString(string: " ")
        imageAttributedString.addAttribute(kCTRunDelegateAttributeName as String, value: runDelegate!, range: NSMakeRange(0, 1))
        
        return imageAttributedString
    }
}
