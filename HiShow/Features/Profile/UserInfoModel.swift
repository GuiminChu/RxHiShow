//
//  UserInfoModel.swift
//  HishowZone
//
//  Created by Chu Guimin on 16/9/10.
//  Copyright © 2016年 Chu Guimin. All rights reserved.
//

import Foundation
import SwiftyJSON

struct UserInfo {
    
    var id: String!
    var uid : String!
    var avatar: String!
    var created: String!
    var desc: String!
    var isBanned: Bool!
    var isSuicide: Bool!
    var largeAvatar: String!
    var locName: String!
    var name: String!
    var signature: String!
    
    init(fromJson json: JSON) {
        if json == JSON.null {
            return
        }
        
        id          = json["id"].stringValue
        uid         = json["uid"].stringValue
        name        = json["name"].stringValue
        desc        = json["desc"].stringValue
        avatar      = json["avatar"].stringValue
        locName     = json["loc_name"].stringValue
        created     = json["created"].stringValue
        isBanned    = json["is_banned"].boolValue
        isSuicide   = json["is_suicide"].boolValue
        signature   = json["signature"].stringValue
        largeAvatar = json["large_avatar"].stringValue
    }
}
