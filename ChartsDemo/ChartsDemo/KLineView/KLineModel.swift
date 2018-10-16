//
//  KLineModel.swift
//  ChartsDemo
//
//  Created by jia on 2018/09/28.
//  Copyright © 2018 jiafujia. All rights reserved.
//

import Foundation

class KLineModel {
    
    var msg: String?
    var datas: [CandleItem] = []
    var code: Int?
    
    init(dic: [String: Any]) {
        msg = dic["msg"] as? String
        code = dic["code"] as? Int
        guard let dataArray = dic["data"] as? [[Any]] else {
            return
        }
        datas = dataArray.map{CandleItem(array: $0)}
    }
}
