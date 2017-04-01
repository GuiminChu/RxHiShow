//
//  BaseViewModel.swift
//  HiShow
//
//  Created by Chu Guimin on 17/3/22.
//  Copyright © 2017年 cgm. All rights reserved.
//

import Moya
import RxSwift
import SwiftyJSON

enum RefreshStatus: Int {
    case dropDownSuccess
    case pullSucessHasMoreData
    case pullSucessNoMoreData
    case invalidData
    case networkerError
}

class BaseViewModel {
    let disposeBag = DisposeBag()
    
    // Variable 类型是 RxSwift 当中特有的一个类型。它是一个泛型，它的 .value 属性指向的就是它的实际参数类型。比如在这里，它的实际参数类型是 RefreshStatus，它是一个枚举类型。Variable 类型的特点在于：只要改变 value 的值，就会发射改变后的数据。
    var refreshStatus = Variable.init(RefreshStatus.invalidData)
    //var refreshStatus = PublishSubject<RefreshStatus>()
}

enum RxSwiftMoyaError: String {
    case ParseJSONError
    case OtherError
}

extension RxSwiftMoyaError: Swift.Error { }
