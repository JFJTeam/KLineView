//
//  CandleItem.swift
//  ChartsDemo
//
//  Created by jia on 2018/09/28.
//  Copyright © 2018 jiafujia. All rights reserved.
//

import Foundation

class CandleItem {
    
    var timeStamp: TimeInterval = 0
    var open: Double = 0
    var close: Double = 0
    var high: Double = 0
    var low: Double = 0
    var volume: Double = 0
    
    init(array: [Any]) {
        timeStamp = (array[0] as! TimeInterval) / 1000
        open = array[1] as! Double
        high = array[2] as! Double
        low = array[3] as! Double
        close = array[4] as! Double
        volume = array[5] as! Double
    }
}
