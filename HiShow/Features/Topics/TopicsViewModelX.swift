//
//  TopicsViewModelX.swift
//  HiShow
//
//  Created by Chu Guimin on 2017/5/18.
//  Copyright © 2017年 cgm. All rights reserved.
//

import RxSwift
import RxCocoa

extension ObservableType {
    public func repeatWhen<TriggerObservable: ObservableConvertibleType>(_ notificationHandler: TriggerObservable) -> Observable<E> {
        return notificationHandler
            .asObservable()
            .map { _ in }
            .startWith(())
            .flatMapLatest { _ in
                return self.asObservable()
        }
    }
}

class TopicsViewModelX: BaseViewModel {
    
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
//
//        let refreshData = input.refreshTriger.debug()
//            .asObservable()
//            .map { 1 }
//            .flatMap {
//                RxHiShowProvider.request(HiShow.topics($0)).mapObject(type: TopicModel.self).map { $0.topics! }
//        }
        
        dataSource = recursivelySearch([], startIndex: 0, loadNextPageTrigger: input.loadNextPageTrigger).repeatWhen(input.refreshTriger)
        
//        dataSource = Observable.from([refreshData, loadMoreData]).merge()
        
//        refreshStatuss = Observable.from([refreshData.map{ _ in true }, loadMoreData.map{ _ in false}]).merge().map { isRefresh in
//            return isRefresh ? RefreshStatus.dropDownSuccess : RefreshStatus.pullSucessHasMoreData
//        }
        
    }
    
    private func recursivelySearch(_ loadedSoFar: [Topic], startIndex: Int, loadNextPageTrigger: Observable<Void>) -> Observable<[Topic]> {
        
        print("h1")
        
        return loadSearchURL(startIndex).flatMap { newTopics -> Observable<[Topic]> in
            var loadedTopics = loadedSoFar
            loadedTopics.append(contentsOf: newTopics)
            
            var index = startIndex
            index += 20
            
            return Observable.concat([
                Observable.just(loadedTopics),
                Observable.never().takeUntil(loadNextPageTrigger.debug()), // takeUntil 接受消息直到loadNextPageTrigger发出消息
                self.recursivelySearch(loadedTopics, startIndex: index, loadNextPageTrigger: loadNextPageTrigger)
            ])
        }
    }
    
    private func loadSearchURL(_ page: Int) -> Observable<[Topic]> {
        print("h3")
        return RxHiShowProvider
            .request(HiShow.topics(page))
            .mapObject(type: TopicModel.self)
            .map { $0.topics! }
    }
}
