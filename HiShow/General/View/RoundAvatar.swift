//
//  RoundAvatar.swift
//  HishowZone
//
//  Created by Chu Guimin on 16/9/6.
//  Copyright © 2016年 Chu Guimin. All rights reserved.
//

import UIKit
import Kingfisher
import Navi

struct RoundAvatar {
    
    let avatarURL: Foundation.URL
    let avatarStyle: AvatarStyle
    var key: String {
        return "navi_\(avatarURL.absoluteString)"
    }
}

let miniAvatarStyle: AvatarStyle = .roundedRectangle(size: CGSize(width: 64, height: 64), cornerRadius: 32, borderWidth: 0)
let nanoAvatarStyle: AvatarStyle = .roundedRectangle(size: CGSize(width: 44, height: 44), cornerRadius: 22, borderWidth: 0)
let picoAvatarStyle: AvatarStyle = .roundedRectangle(size: CGSize(width: 32, height: 32), cornerRadius: 16, borderWidth: 0)

extension RoundAvatar: Navi.Avatar {
    
    var url: URL? {
        return avatarURL
    }
    
    var style: AvatarStyle {
        return avatarStyle
    }
    
    var placeholderImage: UIImage? {
        return nil
    }
    
    var localOriginalImage: UIImage? {
        return nil
    }
    
    var localStyledImage: UIImage? {
        return nil
    }
    
    func save(originalImage: UIImage, styledImage: UIImage) {
        KingfisherManager.shared.cache.store(styledImage, original: nil, forKey: key, toDisk: true, completionHandler: nil)
    }
}
