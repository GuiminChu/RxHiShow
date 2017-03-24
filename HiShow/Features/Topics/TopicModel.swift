//
//  TopicModel.swift
//  HiShow
//
//  Created by Chu Guimin on 16/9/6.
//  Copyright © 2016年 Chu Guimin. All rights reserved.
//

import Foundation
import SwiftyJSON

public protocol Mapable {
    init(jsonData: JSON)
}

struct TopicModel: SwiftyJSONAble {
    
    var count: Int!
    var start: Int!
    var topics: [Topic]!
    var total: Int!
    
    init(jsonData: JSON) {
        if jsonData == JSON.null {
            return
        }
        
        count = jsonData["count"].intValue
        start = jsonData["start"].intValue
        total = jsonData["total"].intValue
        
        topics = [Topic]()
        let topicsArray = jsonData["topics"].arrayValue
        for topicsJson in topicsArray {
            let value = Topic(fromJson: topicsJson)
            // 只展现有照片的话题
            if value.photos.count > 0 {
                // 过滤掉某些没有营养的广告贴
                if value.id != "97583616" && value.id != "79786668" && value.id != "96555462" && value.id != "95243968" && value.id != "91716032" {
                    topics.append(value)
                }
            }
        }
    }
    
//    init(jsonData: JSON) {
//        
//    }
    
    init(fromJson json: JSON) {
        if json == JSON.null {
            return
        }
        
        count = json["count"].intValue
        start = json["start"].intValue
        total = json["total"].intValue
        
        topics = [Topic]()
        let topicsArray = json["topics"].arrayValue
        for topicsJson in topicsArray {
            let value = Topic(fromJson: topicsJson)
            // 只展现有照片的话题
            if value.photos.count > 0 {
                // 过滤掉某些没有营养的广告贴
                if value.id != "97583616" && value.id != "79786668" && value.id != "96555462" && value.id != "95243968" && value.id != "91716032" {
                    topics.append(value)
                }
            }
        }
    }
}

struct Topic {
    
    var id: String!
    var alt: String!
    var author: Author!
    var commentsCount: Int!
    var content: String!
    var created: String!
    var likeCount: Int!
    var photos: [Photo]!
    var title: String!
    var updated: String!
    
    init(fromJson json: JSON) {
        if json == JSON.null {
            return
        }
        
        id            = json["id"].stringValue
        alt           = json["alt"].stringValue
        title         = json["title"].stringValue
        content       = json["content"].stringValue
        created       = json["created"].stringValue
        updated       = json["updated"].stringValue
        likeCount     = json["like_count"].intValue
        commentsCount = json["comments_count"].intValue
        
        let authorJson = json["author"]
        if authorJson != JSON.null {
            author = Author(fromJson: authorJson)
        }
        
        photos = [Photo]()
        let photosArray = json["photos"].arrayValue
        for photosJson in photosArray {
            let value = Photo(fromJson: photosJson)
            photos.append(value)
        }
    }
}

struct Photo {
    
    var id: String?
    var alt: String?
    var authorId: String?
    var creationDate: String?
    var seqId: String?
    var title: String?
    var topicId: String?
    var size: PhotoSize!
    
    init(fromJson json: JSON) {
        if json == JSON.null {
            return
        }
        
        id           = json["id"].stringValue
        alt          = json["alt"].stringValue
        seqId        = json["seq_id"].stringValue
        title        = json["title"].stringValue
        topicId      = json["topic_id"].stringValue
        authorId     = json["author_id"].stringValue
        creationDate = json["creation_date"].stringValue
        
        let sizeJson = json["size"]
        if !sizeJson.isEmpty {
            size = PhotoSize(fromJson: sizeJson)
        }
    }
}

struct PhotoSize {
    
    var height: Int = 1
    var width: Int  = 1
    
    init(fromJson json: JSON) {
        if json.isEmpty {
            return
        }
        
        height = json["height"].intValue
        width = json["width"].intValue
    }
}

/**
 *  作者
 */
struct Author {
    
    var id: String?
    var avatar: String?
    var largeAvatar: String?
    var isSuicide: Bool?
    
    /// 主页地址
    var alt: String?
    /// 昵称
    var name: String?
    
    init(fromJson json: JSON) {
        if json == JSON.null {
            return
        }
        
        id          = json["id"].stringValue
        alt         = json["alt"].stringValue
        name        = json["name"].stringValue
        avatar      = json["avatar"].stringValue
        isSuicide   = json["is_suicide"].boolValue
        largeAvatar = json["large_avatar"].stringValue
    }
}
