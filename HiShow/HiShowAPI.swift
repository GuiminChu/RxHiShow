//
//  HiShowAPI.swift
//  HiShow
//
//  Created by Chu Guimin on 16/9/6.
//  Copyright © 2016年 Chu Guimin. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import Moya
import RxSwift

extension RxMoyaProvider {
    
    func tryUseOfflineCacheThenRequest(token: Target) -> Observable<Moya.Response> {
        return Observable.create { [weak self] observer -> Disposable in
            let key = token.cacheKey // 缓存 Key，可以根据自己的需求来写，这里采用的是 BaseURL + Path + Parameter转化为JSON字符串
//
//            // 先读取缓存内容，有则发出一个信号（onNext），没有则跳过
//            if let response = HSURLCache.sharedInstance.cachedResponseForKey(key) {
//                observer.onNext(response)
//            }
            
//            if let response = URLCache.shared.cachedResponse(for: token.task) {
//                
//            }
            
            
            // 发出真正的网络请求
            let cancelableToken = self?.request(token) { result in
                switch result {
                case let .success(response):
                    observer.onNext(response)
                    observer.onCompleted()
                    
//                    HSURLCache.sharedInstance.cacheResponse(response, forKey: key)
                case let .failure(error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create {
                cancelableToken?.cancel()
            }
        }
    }
}

let HiShowProvider = MoyaProvider<HiShow>()

//let RxHiShowProvider = RxMoyaProvider<HiShow>()

public enum HiShow {
    case topics(Int)
    case userProfile(String)
}

extension TargetType {
    var cacheKey: String {
        return baseURL.absoluteString + path
    }
}

extension HiShow: TargetType {
    
    public var baseURL: URL {
        return URL(string: "https://api.douban.com")!
    }
    
    public var path: String {
        switch self {
        case .topics:
            return "/v2/group/433459/topics"
        case .userProfile(let userId):
            return "/v2/user/\(userId)"
        }
    }
    
    public var method: Moya.Method {
        return .get
    }
    
    public var parameters: [String : Any]? {
        switch self {
        case .topics(let startIndex):
            return ["start": "\(startIndex)", "count": "20"]
        default:
            return nil
        }
    }
    
    public var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    public var task: Task {
        return .requestPlain
    }
    
    public var headers: [String : String]? {
        return nil
    }
    
    public var validate: Bool {
        switch self {
        default:
            return false
        }
    }
    
    public var sampleData: Data {
        switch self {
        case .userProfile:
            return "".data(using: String.Encoding.utf8)!
        case .topics:
            return "".data(using: String.Encoding.utf8)!
        }
    }
}

public enum Reason: CustomStringConvertible {
    case networkError
    case noData
    case other(NSError?)
    
    public var description: String {
        switch self {
        case .networkError:
            return "NetworkError"
        case .noData:
            return "NoData"
        case .other(let error):
            return "Other, Error: \(error?.description)"
        }
    }
}

public typealias FailureHandler = (_ reason: Reason, _ errorMessage: String?) -> Void

public let defaultFailureHandler: FailureHandler = { reason, errorMessage in
    print("\n***************************** YepNetworking Failure *****************************")
    print("Reason: \(reason)")
    if let errorMessage = errorMessage {
        print("errorMessage: >>>\(errorMessage)<<<\n")
    }
}

//https://api.douban.com/v2/group/topic/90364216/comments
//https://api.douban.com/v2/group/topic/90364216

final class HiShowAPI {
    static let sharedInstance = HiShowAPI()
    
    func getTopics(start startIndex: Int, completion: @escaping (TopicModel) -> Void, failureHandler: FailureHandler?) {
        
        let parameters = [
            "start": "\(startIndex)",
            "count": "20"
        ]
        
        Alamofire.request("https://api.douban.com/v2/group/433459/topics", method: .get, parameters: parameters)
            .responseJSON { response in
                switch response.result {
                    
                case .success(let resultValue):
                    let json = JSON(resultValue)
                    
                    // print(json)
                    let topicModel = TopicModel(fromJson: json)
                    
                    completion(topicModel)
                    
                case .failure:
                    failureHandler?(.networkError, "")
                    
                }
        }
    }
    
    func getUserInfo(uid userId: String, completion: @escaping (UserInfo) -> Void, failureHandler: FailureHandler?) {
        
        Alamofire.request("https://api.douban.com/v2/user/\(userId)", method: .get)
            .responseJSON { response in
                
                switch response.result {
                    
                case .success(let resultValue):
                    let json = JSON(resultValue)
                    
                    print(json)
                    let userInfo = UserInfo(fromJson: json)
                    
                    completion(userInfo)
                    
                case .failure:
                    failureHandler?(.networkError, "")
                }
        }
    }
}
