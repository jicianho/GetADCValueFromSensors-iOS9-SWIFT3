//
//  HistoryViewController.swift
//  tempertureBLE
//
//  Created by Jician.ho  on 2017/2/23.
//  Copyright © 2017年 JicianHo. All rights reserved.
//

import UIKit
import Charts
import RealmSwift

class HistoryViewController: UIViewController {
    
//    @IBOutlet weak var barView: BarChartView!
    
    @IBOutlet weak var lineView: LineChartView!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateLabel: UILabel!
    weak var axisFormatDelegate: IAxisValueFormatter? //time
    var dateString: String = ""
    var timeString: String = ""
    var timeInt: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        updateChartWithData()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pickerValueChanged(_ sender: Any) {
        //let formatter = DateFormatter()
        //formatter.dateFormat = "YYYY年 MM月 dd日, a hh:mm"
        //dateLabel.text = formatter.string(from: datePicker.date)
        updateChartWithData()
        
    }
    
    func pickerValueUpdated(){ //更新所選的日期
        let formatter = DateFormatter()
        let checkDateBaseLineDateFormatter = DateFormatter()
        let checkDateBaseLineTimeFormatter = DateFormatter()
        formatter.dateFormat = "YYYY年 MM月 dd日, a hh:mm"
        checkDateBaseLineDateFormatter.dateFormat = "YYYYMMdd"
        checkDateBaseLineTimeFormatter.dateFormat = "HHmm"
        dateLabel.text = formatter.string(from: datePicker.date)
        dateString = checkDateBaseLineDateFormatter.string(from: datePicker.date)
        timeString = checkDateBaseLineTimeFormatter.string(from: datePicker.date)
        timeInt = Int(timeString)!
        dateLabel.text = formatter.string(from: datePicker.date)
    }
    
    func getVisitorCountsFromDatabase() -> Results<ChartsDatas> {
        do {
            let realm = try Realm()
            //print (realm.configuration.fileURL)
            //file:///var/mobile/Containers/Data/Application/5492A9DA-063A-483B-879D-10CCED749775/Documents/default.realm
            //return realm.objects(ChartsDatas.self)
            let predicate = "dateYYYYMMdd BEGINSWITH '\(dateString)' AND dateHHmmToInt < \(timeInt-1)"
            print("\(predicate)")
            let pickDate = realm.objects(ChartsDatas.self).filter(predicate)
            return pickDate
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
//    func updateChartWithData() {
//        pickerValueUpdated()
//        var dataEntries: [BarChartDataEntry] = []
//        let visitorCounts = getVisitorCountsFromDatabase()
//        
//        var xAxisCount = visitorCounts.count //visitorCounts.count 是資料庫筆數
//        if xAxisCount > 10{
//            xAxisCount = visitorCounts.count - 10 //取最新的十筆
//        }
//        for i in xAxisCount..<visitorCounts.count {
//            let timeIntervalForDate: TimeInterval = visitorCounts[i].date.timeIntervalSince1970
//            let dataEntry = BarChartDataEntry(x: Double(timeIntervalForDate), y: Double(visitorCounts[i].count))
//            dataEntries.append(dataEntry)
//        }
//        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Temperture")
//        let chartData = BarChartData(dataSet: chartDataSet)
//        
//        barView.data = chartData
//        
//        let xaxis = barView.xAxis
//        xaxis.valueFormatter = axisFormatDelegate
//    }
    func updateChartWithData(){
        pickerValueUpdated()
        var dataEntries: [ChartDataEntry] = []
        let visitorCounts = getVisitorCountsFromDatabase()
        
        
        var xAxisCount = visitorCounts.count //visitorCounts.count 是資料庫筆數
        if xAxisCount > 10{
            xAxisCount = visitorCounts.count - 10 //取最新的十筆
        }
        for i in xAxisCount..<visitorCounts.count {
            let timeIntervalForDate: TimeInterval = visitorCounts[i].date.timeIntervalSince1970
            let dataEntry = ChartDataEntry(x: Double(timeIntervalForDate), y: Double(visitorCounts[i].count))
            dataEntries.append(dataEntry)
        }
        //let chartDataSet = BarChartDataSet(values: dataEntries, label: "Temperture")
        //let chartDataSet = LineChartDataSet(values: dataEntries,label: "Temperture")
        //let chartData = LineChartData(dataSet: chartDataSet)
        let lineChartDataSet = LineChartDataSet(values: dataEntries, label: "Temperture")
        lineChartDataSet.mode = .cubicBezier
        lineChartDataSet.drawCirclesEnabled = true //不畫外環
        lineChartDataSet.drawCircleHoleEnabled = true
        lineChartDataSet.circleRadius = 5
        lineChartDataSet.circleHoleRadius = 2
        let lineChartData = LineChartData(dataSet: lineChartDataSet)
        print("\( lineChartData.entryCount )")
        if (lineChartData.entryCount > 0){
            lineView.data = lineChartData
            let xaxis = lineView.xAxis
            xaxis.valueFormatter = axisFormatDelegate
        }else{
            //資料量不足十筆
        }
    }
    


}
// MARK: axisFormatDelegate
extension HistoryViewController: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }
}
