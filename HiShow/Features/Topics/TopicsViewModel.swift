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
//    var startIndex = 0
    
    let startIndex = Variable(1)
    
    var isPullToRefresh = Variable<Bool>(true)
    
    
    var refreshStatuss = Observable<RefreshStatus>.empty()
    
    init(input: (refreshTriger: Observable<Void>, loadNextPageTrigger: Observable<Void>)) {
        
        super.init()

        let refreshData = input.refreshTriger.debug()
            .asObservable()
            .map { 1 }
            .flatMap {
//                RxHiShowProvider.request(HiShow.topics($0)).mapObject(type: TopicModel.self).map { $0.topics! }
                HiShowProvider.rx.request(HiShow.topics($0)).mapObject(type: TopicModel.self).map { $0.topics! }
            }
        
        
        
//        let loadMoreData = input.loadNextPageTrigger.asObservable()
//            .map { 1 }
//            .scan(0) { (a, b) in
//                print("1")
//                return a + b
//            }
//            .flatMap {
//                RxHiShowProvider.request(HiShow.topics($0)).mapObject(type: TopicModel.self).map { $0.topics! }
//            }
//            .scan(dataSource.v) { (acum, elem) in
//                print("2")
//                print(acum.count)
//                return acum + elem
//            }
        
        
        let loadMoreData = recursivelySearch([], loadNextPageTrigger: input.loadNextPageTrigger)
        
        
//        let loadMoreData1 = input.loadNextPageTrigger
//            .asObservable()
//            .withLatestFrom(startIndex.asDriver())
//            .flatMap {
//                RxHiShowProvider.request(HiShow.topics($0)).mapObject(type: TopicModel.self).map { $0.topics! }
//            }.reduce([Topic]()) { (acum, elem) in
//                return acum + elem
//            }
    
        dataSource = Observable.from([refreshData, loadMoreData]).merge()
        
//         Observable.from([refreshData, loadMoreData]).merge().bindTo(dataSource)
        
        //refreshStatus = Observable.of(refreshData)
 //       refreshStatuss = Observable.from([refreshData]).asObservable().map { _ in
   //         return RefreshStatus.dropDownSuccess
  //      }

        refreshStatuss = Observable.from([refreshData.map{ _ in true }, loadMoreData.map{ _ in false}]).merge().map { isRefresh in
            return isRefresh ? RefreshStatus.dropDownSuccess : RefreshStatus.pullSucessHasMoreData
        }
        
    }
    
    private func recursivelySearch(_ loadedSoFar: [Topic], loadNextPageTrigger: Observable<Void>) -> Observable<[Topic]> {
        
        print("h1")
        
        return loadSearchURL(1).flatMap { newTopics -> Observable<[Topic]> in
            var loadedTopics = loadedSoFar
            loadedTopics.append(contentsOf: newTopics)
            
            print("h2")
            
            return Observable.concat([Observable.just(loadedTopics),
                                          Observable.never().takeUntil(loadNextPageTrigger), // takeUntil 接受消息直到loadNextPageTrigger发出消息
                                          self.loadSearchURL(1)])
            
//            return xxxx
        }

    }
    
    private func loadSearchURL(_ page: Int) -> Observable<[Topic]> {
        print("h3")
        return RxHiShowProvider.request(HiShow.topics(page)).mapObject(type: TopicModel.self).map { $0.topics! }
    }
    
//    func getTopics(isPullToRefresh: Bool) -> Observable<[Topic]> {
//        
//        if isPullToRefresh {
//            startIndex = 0
//        } else {
//            startIndex += 20
//        }
//        
//        let xx =  RxHiShowProvider.request(HiShow.topics(startIndex)).mapObject(type: TopicModel.self).map { $0.topics! }
//        
//        return xx
//    }
    
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

/*
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
 */
