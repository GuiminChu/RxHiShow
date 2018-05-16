//
//  Observable+SwiftyJSON.swift
//  HiShow
//
//  Created by Chu Guimin on 17/3/23.
//  Copyright © 2017年 cgm. All rights reserved.
//

import Moya
import RxSwift
import SwiftyJSON

protocol SwiftyJSONAble {
    init?(jsonData: JSON)
}

extension Observable {
    
    func mapObject<T: SwiftyJSONAble>(type: T.Type) -> Observable<T> {
        return self.map({ response in
            guard let response = response as? Moya.Response else {
                throw RxSwiftMoyaError.ParseJSONError
            }
            
            guard let object = T(jsonData: JSON(data: response.data)) else {
                throw RxSwiftMoyaError.ParseJSONError
            }
            
            return object
        })
    }
}
