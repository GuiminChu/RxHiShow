//
//  TopicsViewModel.swift
//  HiShow
//
//  Created by Chu Guimin on 17/3/23.
//  Copyright © 2017年 cgm. All rights reserved.
//

import Foundation
import RxSwift

class TopicsViewModel: BaseViewModel {
    
    var dataSource = Variable([Topic]())
    
    /// 分页参数，第一页为0
    var startIndex = 0
    
    func getTopics(isPullToRefresh: Bool) {
        
        if isPullToRefresh {
            startIndex = 0
        } else {
            startIndex += 20
        }
        
        rxHiShowProvider.request(HiShow.topics(startIndex))
            .mapObject(type: TopicModel.self).subscribe(onNext: { [weak self] topicModel in
                if isPullToRefresh {
                    self?.refreshStatus.value = .dropDownSuccess
                    self?.dataSource.value = topicModel.topics
                } else {
                    self?.refreshStatus.value = .pullSucessHasMoreData
                    self?.dataSource.value.append(contentsOf: topicModel.topics)
                }
            }, onError: { error in
                self.refreshStatus.value = .networkerError
                
            }, onCompleted: {
                print("comp")
            })
            .addDisposableTo(disposeBag)
    }
}
