//
//  TopicsViewModel.swift
//  HiShow
//
//  Created by Chu Guimin on 17/3/23.
//  Copyright © 2017年 cgm. All rights reserved.
//

import RxSwift
import RxCocoa

class TopicsViewModel: BaseViewModel {
    
//    var dataSource = Variable([Topic]())
    var dataSource = Observable<[Topic]>.empty()
    
     var test = Observable<(Topic, RefreshStatus)>.empty()
    
    /// 分页参数，第一页为0
    var startIndex = 0
    
    var isPullToRefresh = Variable<Bool>(true)
    
//    init(loadNextPageTrigger: Driver<Void>) {
//        
//        loadNextPageTrigger.asObservable().subscribe(onNext: {
//            print("load")
//        })
//    }
    
      override init() {
        
//        dataSource = isPullToRefresh.asObservable().flatMapLatest { isPull in
//            let xx = self?.getTopics(isPullToRefresh: isPull)
//            return xx
//        }
        
//        let xxx = isPullToRefresh.asObservable().map { isPull -> Observable<[Topic]> in
//            let xx = self.getTopics(isPullToRefresh: isPull)
//            return xx
//        }
        
        dataSource = isPullToRefresh.asObservable().flatMapLatest { isPull -> Observable<[Topic]> in
            let xx = rxHiShowProvider.request(HiShow.topics(0)).mapObject(type: TopicModel.self).map { $0.topics! }
            return xx
        }

//        dataSource = rxHiShowProvider.request(HiShow.topics(startIndex)).mapObject(type: TopicModel.self).map { topicModel in
//            return topicModel.topics
//        }
    }
    
        func getTopics(isPullToRefresh: Bool) -> Observable<[Topic]> {
    
            if isPullToRefresh {
                startIndex = 0
            } else {
                startIndex += 20
            }
    
            let xx =  rxHiShowProvider.request(HiShow.topics(startIndex)).mapObject(type: TopicModel.self).map { $0.topics! }
            
            return xx
        }
    
//    func getTopics(isPullToRefresh: Bool) {
//        
//        if isPullToRefresh {
//            startIndex = 0
//        } else {
//            startIndex += 20
//        }
//        
//        rxHiShowProvider.request(HiShow.topics(startIndex))
//            .mapObject(type: TopicModel.self).subscribe(onNext: { [weak self] topicModel in
//                if isPullToRefresh {
//                    self?.refreshStatus.value = .dropDownSuccess
//                    self?.dataSource.value = topicModel.topics
//                } else {
//                    self?.refreshStatus.value = .pullSucessHasMoreData
//                    self?.dataSource.value.append(contentsOf: topicModel.topics)
//                }
//            }, onError: { error in
//                self.refreshStatus.value = .networkerError
//                
//            }, onCompleted: {
//                print("comp")
//            })
//            .addDisposableTo(disposeBag)
//        
//        
//    }
}

class PhgViewModel {
    let refreshTrigger = PublishSubject<Void>()
    let loadNextPageTrigger = PublishSubject<Void>()
    let elements = Variable<[Brand]>([])
    let page = Variable(1)
    let hasNextPage = Variable(true)
    let refreshing = Variable(false)
    let loading = Variable<Bool>(true)
    let error = PublishSubject<ErrorType>()
    
    init(input: (refreshTriger: Observable<Void>, loadMoreTriger: Observable<Void>)) {
        let refreshRequest: Observable<Result<[Brand],NSError>> = input.refreshTriger
            .map {1}
            .flatMapLatest { page -> Observable<Result<[String : AnyObject],NSError>> in
                EmeAPI.sharedInstance.request(PhgApi.getList(begin: page , length: 10))
                    .observeOn(Mainscheduler.instance)
                    .mapRegMessageData([String : AnyObject])
                    .map{Result.Success($0)}
                    .catchError{ error in
                        let errir  = error as NSError
                        let right = Result<[String : AnyObject], NSError>> in
                        return Observable.just(right)
                }
            }.flatMapLatest { response -> Observable<Result<[Brand],NSError>> in
                return Observable.create { observer -> Disposable in
                    switch response {
                    case .Success(let relDict):
                        if let brand = Mapper<Brand>().mapArray(relDict["list"]){
                            observer.onNext(Result.Success(brand))
                        }
                        observer.onNext(Result.Failure(NSError.init(domain: "获取数据错误", code: 100, userInfo: nil)))
                    case .Failure(let error):
                        observer.onNext(Result.Failure(error))
                    }
                    return NoDisposable.instance
                }
        }
        refreshRequest.subscribeNext{ [weak self]  result in
            switch result {
            case .Success(let branch):
                self?.page.value  = 2
                self?.elements.value = brands
            case .Failure(  let error) :
                print(error)
            }
        }
    }
}
