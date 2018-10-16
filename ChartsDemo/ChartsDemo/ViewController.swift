//
//  ViewController.swift
//  ChartsDemo
//
//  Created by jia on 2018/09/27.
//  Copyright © 2018 jiafujia. All rights reserved.
//

import UIKit
import Charts

class ViewController: UIViewController {

    lazy var kView: KLineView = {
        let kView = KLineView()
        kView.frame = CGRect(x: 0, y: 40, width: UIScreen.main.bounds.width, height: 500)
        view.addSubview(kView)
        return kView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        generateDynamicData()
    }
    
    func generateDynamicData() {
        if #available(iOS 10.0, *) {
            var lower = Double.random(lower: 5000, upper: 10000)
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {_ in
                guard let candleItem = self.kView.kLineList.last else { return }
                DispatchQueue.global().async {
                    var isAddedNewItem = false
                    var current = Double.random(lower: lower, upper: lower + 1500)
                    let now = floor(Date().timeIntervalSince1970)
                    
                    if now - candleItem.timeStamp > 30 {
                        let open = candleItem.close
                        lower = Double.random(lower: 5000, upper: 8000)
                        current = Double.random(lower: lower, upper: lower + 1500)
                        let newItem = CandleItem(array: [now * 1000, open, current, current, current, 1.0])
                        self.kView.kLineList.append(newItem)
                        isAddedNewItem = true
                    } else {
                        candleItem.close = current
                        if candleItem.high < current { candleItem.high = current }
                        if candleItem.low > current { candleItem.low = current }
                        candleItem.volume += Double(Int.random(lower: 100, upper: 1000))
                    }
                    
                    DispatchQueue.main.async {
                        self.kView.currentValue  = current
                        self.kView.reloadData(dataList: self.kView.kLineList, shouldAutoMove: isAddedNewItem)
                    }
                }
            }
        }
    }
    
    private func setupData() {
        guard let jsonPath = Bundle.main.path(forResource: "k_line_data", ofType: "json") else {
            return
        }
        let data = try! Data(contentsOf: URL(fileURLWithPath: jsonPath))
        let klineDict = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
     
        let model = KLineModel(dic: klineDict as! [String : Any])
        kView.reloadData(dataList: model.datas)
    }
}





