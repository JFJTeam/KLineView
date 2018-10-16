//
//  Array+Extension.swift
//  ChartsDemo
//
//  Created by jia on 2018/10/09.
//  Copyright © 2018 jiafujia. All rights reserved.
//

import Foundation

extension Array where Array.Element: AnyObject {
    
    func index(of element: Element) -> Int? {
        for (currentIndex, currentElement) in self.enumerated() {
            if currentElement === element {
                return currentIndex
            }
        }
        return nil
    }
}

extension Double {
    public static func random(lower: Double = 0,upper: Double = 100) -> Double {
        return (Double(arc4random())/Double(UInt32.max))*(upper - lower) + lower
    }
}

extension Int {
    public static func random(lower: Int = 0,upper: Int = 100) -> Int {
        return Int(arc4random() % UInt32(upper) + UInt32(lower))
    }
}

