//
//  CacheHelper.swift
//  HiShow
//
//  Created by Chu Guimin on 2017/5/19.
//  Copyright © 2017年 cgm. All rights reserved.
//

import Moya
import Cache

struct CacheHelper {
    static let shared = CacheHelper()
    
    func cachedResponse(forKey key: String) -> Moya.Response {
        
        let cache = HybridCache(name: key)
        cache.object("\(key)StatusCode") { statusCode in
            <#code#>
        }
        
        
        let xx = Response(statusCode: <#T##Int#>, data: <#T##Data#>, request: <#T##URLRequest?#>, response: URLResponse?)
        
        
    }
    
    func cache(response: Response, key: String)  {
        let cache = HybridCache(name: key)
        cache.add("\(key)StatusCode", object: "\(response.statusCode)")
        cache.add("\(key)Data", object: response.data)
    }
}
