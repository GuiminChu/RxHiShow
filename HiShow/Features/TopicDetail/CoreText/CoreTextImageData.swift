//
//  CoreTextImageData.swift
//  HiShow
//
//  Created by Chu Guimin on 17/3/8.
//  Copyright © 2017年 cgm. All rights reserved.
//

import UIKit

class CoreTextImageData: NSObject {
    var name: String?               // 图片名称
    var title: String?              // 图片描述
    var image: UIImage?             // 图片
    var imageUrl: String?           // 图片链接地址
    var imagePosition = CGRect.zero // 此坐标是 CoreText 的坐标系，而不是UIKit的坐标系
}
