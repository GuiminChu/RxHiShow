//
//  HiShowConfig.swift
//  HiShow
//
//  Created by Chu Guimin on 17/3/9.
//  Copyright © 2017年 cgm. All rights reserved.
//

import UIKit
import Foundation

let kScreenWidth = UIScreen.main.bounds.width
let kScreenHeight = UIScreen.main.bounds.height

struct HiShowConfig {
    
    public struct NotificationName {
        
        public static let coreTextImagePressedNotification = Notification.Name(rawValue: "HiShowConfig.Notification.CTDisplayViewImagePressed")
    }
}
