//
//  CoreTextData.swift
//  HiShow
//
//  Created by Chu Guimin on 17/3/8.
//  Copyright © 2017年 cgm. All rights reserved.
//

import UIKit

class CoreTextData: NSObject {
    
    var ctFrame: CTFrame
    var height: CGFloat
    var imageArray: [CoreTextImageData] = [CoreTextImageData]() {
        willSet {
            fillImagePosition(imageArray: newValue)
        }
        
    }
    
    init(ctFrame: CTFrame, height: CGFloat) {
        self.ctFrame = ctFrame
        self.height = height
    }
    
    private func fillImagePosition(imageArray: [CoreTextImageData]) {
        if imageArray.count == 0 {
            return
        }
        
        let lines = CTFrameGetLines(ctFrame) as Array
        var originsArray = [CGPoint](repeating: CGPoint.zero, count:lines.count)
        // 把 CTFrame 里每一行的初始坐标写到数组里
        CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, 0), &originsArray)
        
        var imgIndex : Int = 0
        var imageData: CoreTextImageData? = imageArray[0]
        
        for index in 0..<lines.count {
            
            guard imageData != nil else {
                return
            }
            
            let line = lines[index] as! CTLine
            let runObjArray = CTLineGetGlyphRuns(line) as Array
            
            for runObj in runObjArray {
                let run = runObj as! CTRun
                let runAttributes = CTRunGetAttributes(run) as NSDictionary
                let delegate = runAttributes.value(forKey: kCTRunDelegateAttributeName as String)
                
                if delegate == nil {
                    continue
                }
                
                var runBounds = CGRect()
                var ascent: CGFloat = 0
                var descent: CGFloat = 0
                
                runBounds.size.width = CGFloat(CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, nil))
                runBounds.size.height = ascent + descent
                
                let xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, nil)
                runBounds.origin.x = originsArray[index].x + xOffset
                runBounds.origin.y = originsArray[index].y
                runBounds.origin.y -= descent
                
                let path = CTFrameGetPath(ctFrame)
                
                let colRect = path.boundingBox
                
                let delegateBounds = runBounds.offsetBy(dx: colRect.origin.x, dy: colRect.origin.y)
                
                imageData!.imagePosition = delegateBounds
                
                imgIndex += 1
                if imgIndex == imageArray.count {
                    imageData = nil
                    break
                } else {
                    imageData = imageArray[imgIndex]
                }
            }
        }
    }
}
