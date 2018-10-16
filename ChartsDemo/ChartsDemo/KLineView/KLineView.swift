//
//  KLineView.swift
//  ChartsDemo
//
//  Created by jia on 2018/09/28.
//  Copyright © 2018 jiafujia. All rights reserved.
//

import UIKit
import Charts

let kBackColor = UIColor(white: 0.1, alpha: 1.0)
let kCombineHeightRatio: CGFloat = 3/4
let kAxisColor = UIColor(white: 0.5, alpha: 1.0)

enum LineType: Int {
    case M5 = 5
    case M10 = 10
    case M20 = 20
}

class KLineView: UIView {
    
    var kLineList = [CandleItem]()
    var currentValue: Double = 0 {
        didSet {
            showCurrentLabel()
        }
    }
    
    fileprivate lazy var combineChart: CombinedChartView = {
        let chart = CombinedChartView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height * kCombineHeightRatio))
        addSubview(chart)
        setChartStyle(chart: chart)
        return chart
    }()
    
    fileprivate lazy var barChart: BarChartView = {
        let chart = BarChartView(frame: CGRect(x: 0, y: bounds.height * kCombineHeightRatio, width: bounds.width, height:  bounds.height * (1 - kCombineHeightRatio)))
        addSubview(chart)
        setChartStyle(chart: chart)
        chart.doubleTapToZoomEnabled = false
        return chart
    }()
    
    fileprivate lazy var currentLabel: UILabel = {
        let labelWidth: CGFloat = 40
        let label = UILabel(frame: CGRect(x: combineChart.frame.width - labelWidth, y: 0, width: labelWidth, height: 15))
        label.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = UIColor(white: 1, alpha: 0.8)
        combineChart.addSubview(label)
        return label
    }()
    
    private func setChartStyle(chart: BarLineChartViewBase) {
        chart.delegate = self
        chart.autoScaleMinMaxEnabled = true
        chart.scaleXEnabled = false
        chart.scaleYEnabled = false
        chart.chartDescription?.enabled = false
        chart.maxVisibleCount = 0
        chart.backgroundColor = kBackColor
        chart.legend.enabled = false
        chart.minOffset = 0
        
        chart.leftAxis.enabled = false
        let rightAxis = chart.rightAxis
        rightAxis.labelTextColor = kAxisColor
        rightAxis.labelCount = 5
        rightAxis.drawGridLinesEnabled = true
        rightAxis.gridLineDashLengths = [5,5]
        rightAxis.labelPosition = .outsideChart
        
        let xAxis = chart.xAxis
        xAxis.drawGridLinesEnabled = false
        xAxis.drawAxisLineEnabled = true
        xAxis.labelTextColor = kAxisColor
        xAxis.labelPosition = .bottom
        xAxis.labelCount = 5
        xAxis.valueFormatter = self
        xAxis.avoidFirstLastClippingEnabled = true
        xAxis.granularity = 1
    }
    
    fileprivate func fillLineView(_ shouldAutoMove: Bool = true) {
        combineChart.viewPortHandler.setMaximumScaleX(1.5)
        let combineData = CombinedChartData()
        combineData.lineData = generateLineData()
        combineData.candleData = generateCandleData()
        combineChart.data = combineData
        combineChart.xAxis.axisMaximum = combineData.xMax + 0.5
        combineChart.xAxis.axisMinimum = -0.5
        combineChart.setVisibleXRangeMaximum(50)
        if shouldAutoMove {
            combineChart.moveViewToX(Double(kLineList.count - 1))
        }

//        highlightLast()
    }
    
    
    fileprivate func fillBarView(_ shouldAutoMove: Bool = true) {
        let yValues = kLineList.map {
            BarChartDataEntry(x: Double(kLineList.index(of: $0)!), y: Double($0.volume))
        }

        let set = BarChartDataSet(values: yValues, label: nil)
        set.drawValuesEnabled = true
        set.highlightEnabled = true
        set.colors = getBarColors()
        
        barChart.data = BarChartData(dataSet: set)
        barChart.setVisibleXRangeMaximum(50)

        let srcMatrix = combineChart.viewPortHandler.touchMatrix
        barChart.viewPortHandler.refresh(newMatrix: srcMatrix, chart: barChart, invalidate: true)
        if shouldAutoMove {
            combineChart.moveViewToX(Double(kLineList.count - 1))
        }
    }
    
    fileprivate func highlightLast() {
        let highlight = combineChart.getHighlightByTouchPoint(CGPoint(x: combineChart.frame.width, y: 10))
        combineChart.highlightValue(highlight, callDelegate: true)
    }

    private func getBarColors() -> [NSUIColor] {
        return kLineList.map { (item) -> UIColor in
            item.close >= item.open ? ChartColorTemplates.colorFromString("#0033ff") : ChartColorTemplates.colorFromString("#ff3300")
        }
    }
    
    private func generateLineData() -> LineChartData {
        return LineChartData(dataSets: [getLineChartSet(.M5),
                                        getLineChartSet(.M10),
                                        getLineChartSet(.M20)])
    }
    
    private func generateCandleData() -> CandleChartData {
        let yValues = kLineList.map { (item) -> CandleChartDataEntry in
            return CandleChartDataEntry(x: Double(kLineList.index(of: item)!), shadowH: item.high, shadowL: item.low, open: item.open, close: item.close)
        }
        let set = CandleChartDataSet(values: yValues, label: "K Line")
        set.shadowColorSameAsCandle = true
        set.highlightEnabled = true
        set.highlightColor = UIColor.green
//        set.drawVerticalHighlightIndicatorEnabled = false
        set.axisDependency = .right
        set.setColor(UIColor(white: 80/255, alpha: 1.0))
        set.drawIconsEnabled = false
        set.shadowWidth = 0.7
        set.decreasingFilled = true
        set.decreasingColor = ChartColorTemplates.colorFromString("#ff3300")
        set.increasingFilled = true
        set.increasingColor = ChartColorTemplates.colorFromString("#0033ff")
        set.neutralColor = ChartColorTemplates.colorFromString("#0000ff")
        return CandleChartData(dataSet: set)
    }
    
    private func getLineChartSet(_ lineType: LineType) -> LineChartDataSet {
        let closePriceList = getClosePriceList(lineType.rawValue)
        
        let yValues = closePriceList.map {
            ChartDataEntry(x: Double(lineType.rawValue - 1 + closePriceList.index(of: $0)!), y: Double($0)!)
        }
        let set = LineChartDataSet(values: yValues, label: "M\(lineType.rawValue)")
        configLineSet(set)
        var setColor: UIColor
        switch lineType {
        case .M5:
            setColor = .white
        case .M10:
            setColor = .yellow
        default:
            setColor = UIColor(red: 119/255, green: 206/255, blue: 1, alpha: 1)
        }
        set.setColor(setColor)
        set.fillColor = setColor
        return set
    }
    
    private func getClosePriceList(_ days: Int) -> [String] {
        let day = days - 1
        var closePrice = [String]()
        for i in 0..<kLineList.count {
            let index = kLineList.count - 1 - i
            if index < day { continue }
            var allClosePrice = 0.0
            for j in (index - day)...index {
                let item = kLineList[j]
                allClosePrice += item.close
            }
            let closePriceStr = String(format: "%f", allClosePrice / Double(days))
            closePrice.insert(closePriceStr, at: 0)
        }
        return closePrice
    }
    
    private func configLineSet(_ set: LineChartDataSet) {
        set.lineWidth = 1
        set.highlightEnabled = false
        set.mode = .cubicBezier
        set.drawValuesEnabled = false
        set.axisDependency = .right
        set.drawCirclesEnabled = false
    }
    
    private func showCurrentLabel() {
        currentLabel.text = String(format: "%.1f", currentValue)
        let y = (combineChart.frame.height - combineChart.xAxis.labelHeight - 3) * CGFloat(1 - (currentValue - combineChart.chartYMin) / (combineChart.chartYMax - combineChart.chartYMin)) - (currentLabel.frame.height / 2)
        currentLabel.frame.origin.y = y
    }
}

// MARK: -  Public Methods
extension KLineView {
    
    public func reloadData(dataList: [CandleItem], shouldAutoMove: Bool = true) {
        guard dataList.count > 0 else {
            return
        }
        kLineList = dataList
        fillLineView(shouldAutoMove)
        fillBarView(shouldAutoMove)
    }
}

// MARK: - ChartViewDelegate
extension KLineView: ChartViewDelegate {
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
//        showMarkView(kLineList[Int(entry.x)].open)
    }
    
    func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {
        refreshMatrix(chartView)
    }
    
    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
        refreshMatrix(chartView)
//        highlightLast()
    }
    
    private func refreshMatrix(_ chartView: ChartViewBase) {
        let srcMatrix = chartView.viewPortHandler.touchMatrix
        combineChart.viewPortHandler.refresh(newMatrix: srcMatrix, chart: combineChart, invalidate: true)
        barChart.viewPortHandler.refresh(newMatrix: srcMatrix, chart: barChart, invalidate: true)
    }
    
    private func showMarkView(_ value: Double) {
        let markView = MarkerView(frame: CGRect(x: 20, y: 20, width: 80, height: 20))
        markView.chartView = combineChart
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 20))
        label.text = "o:\(value)"
        label.font = UIFont.systemFont(ofSize: 12)
        label.backgroundColor = UIColor.gray
        label.textAlignment = .center
        markView.addSubview(label)
        combineChart.marker = markView
    }
}

extension KLineView: IAxisValueFormatter {
    
    // axis x should depends on the period
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        guard Int(value) < kLineList.count else {
            return ""
        }
        let interval = kLineList[Int(value)].timeStamp
        let date = Date(timeIntervalSince1970: interval)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        var dateStr = formatter.string(from: date)
        if dateStr == "00:00" {
            formatter.dateFormat = "MM/dd"
            dateStr = formatter.string(from: date)
        }
        return dateStr
    }
}
