//
//  ViewController.swift
//  tempertureBLE
//
//  Created by Jician.ho  on 2017/2/8.
//  Copyright © 2017年 JicianHo. All rights reserved.
//

import UIKit
import CoreBluetooth
import Charts
import RealmSwift
import UserNotifications

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    var members = [BLEMember]()
    var centralManager:CBCentralManager!
    var qPeripheral:CBPeripheral!
    var tempValue: UInt32 = 0
    var tempCount: Int = 0
    var dateString: String = ""
    var timeString: String = ""
    var timeInt: Int = 0
    let button:UIButton = UIButton(type:.contactAdd)
    var intString = "25"
    var decString = "0"
    var alertSwitchBool = false
    @IBOutlet weak var lineView: LineChartView!
    
    @IBOutlet weak var tfValue: UITextField!
    @IBOutlet weak var deviceConnectOutlet: UIButton!
    @IBOutlet weak var historyOutlet: UIButton!
    @IBOutlet weak var warnningOutlet: UIButton!
    
    @IBOutlet weak var alertIcon: UIImageView!

    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var deviceName: UILabel!
    
    weak var axisFormatDelegate: IAxisValueFormatter? //time
    
//    @IBAction func btnAddTapped(_ sender: Any) {
//        if let value = tfValue.text , value != "" {
//            let visitorCount = ChartsDatas()
//            visitorCount.count = Double(value)!
//            visitorCount.save()
//            tfValue.text = ""
//            tfValue.resignFirstResponder()
//        }
//        updateChartWithData()
//    }
    @IBOutlet weak var tempertureDisplay: UILabel!
    @IBAction func deviceConnect(_ sender: UIButton) {
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    @IBAction func alertSwitch(_ sender: Any) {
        let getString = readUser()
        var messageString = "" 
        if (!alertSwitchBool){
            messageString = "溫度警示開啟，設定為\(getString)度"
            alertSwitchBool = true
            alertIcon.isHidden = false
            alertLabel.isHidden = false
            alertLabel.text = readUser() + "°C"
        }else{
            messageString = "溫度警示關閉"
            alertSwitchBool = false
            alertIcon.isHidden = true
            alertLabel.isHidden = true
            lineView.rightAxis.removeAllLimitLines()
        }
        let alert = UIAlertController(title: "溫度警示", message: messageString, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        axisFormatDelegate = self //time
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        buttonLayout()
        
        lineView.noDataText = "No Enough Chart Data Available"
        lineView.animate(xAxisDuration: 1)
        
        
        //alert setting
        alertLabel.text = readUser() + "°C"
        alertIcon.isHidden = true
        alertLabel.isHidden = true
        
        //device name setting
        deviceName.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func buttonLayout(){
        
        let menuButtonBGC:UIColor = UIColor(red:0.88 ,green:0.96 ,blue:1.00, alpha:1.0)
        let menuButtonCornerRadius:CGFloat = 5
        let menuButtonBorderWidth:CGFloat = 1
        let menuButtonBorderColor:CGColor = UIColor.brown.cgColor
        
        deviceConnectOutlet.backgroundColor = menuButtonBGC
        deviceConnectOutlet.layer.cornerRadius = menuButtonCornerRadius
        deviceConnectOutlet.layer.borderWidth = menuButtonBorderWidth
        deviceConnectOutlet.layer.borderColor = menuButtonBorderColor
        
        historyOutlet.backgroundColor = menuButtonBGC
        historyOutlet.layer.cornerRadius = menuButtonCornerRadius
        historyOutlet.layer.borderWidth = menuButtonBorderWidth
        historyOutlet.layer.borderColor = menuButtonBorderColor
        
        warnningOutlet.backgroundColor = menuButtonBGC
        warnningOutlet.layer.cornerRadius = menuButtonCornerRadius
        warnningOutlet.layer.borderWidth = menuButtonBorderWidth
        warnningOutlet.layer.borderColor = menuButtonBorderColor
        
    }
    
    func pickerValueUpdated(){ //更新現在時間
        let dateFormatter = DateFormatter()
        let timeFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYMMdd"
        timeFormatter.dateFormat = "HHmm"
        dateString = dateFormatter.string(from: Date())
        timeString = timeFormatter.string(from: Date())
        timeInt = Int(timeString)!
    }
    /*
    func updateChartWithData() {
        var dataEntries: [BarChartDataEntry] = [] //直方圖陣列
        let visitorCounts = getVisitorCountsFromDatabase()//把整個database讀進來
        
        var xAxisCount = visitorCounts.count //visitorCounts.count 是資料庫筆數
        if xAxisCount > 10{
            xAxisCount = visitorCounts.count - 10 //取最新的十筆
        }
        for i in xAxisCount..<visitorCounts.count {
            let timeIntervalForDate: TimeInterval = visitorCounts[i].date.timeIntervalSince1970
            let dataEntry = BarChartDataEntry(x: Double(timeIntervalForDate), y: Double(visitorCounts[i].count))
            dataEntries.append(dataEntry)
        }
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Temperture")
        let chartData = BarChartData(dataSet: chartDataSet)
        barView.data = chartData
        
        let xaxis = barView.xAxis
        xaxis.valueFormatter = axisFormatDelegate
    }
    */
    
    func updateChartWithData(){
        alertLabel.text = readUser() + "°C"
        var dataEntries: [ChartDataEntry] = []
        let visitorCounts = getVisitorCountsFromDatabase()

        
        var xAxisCount = visitorCounts.count //visitorCounts.count 是資料庫筆數
        if xAxisCount > 10{
            xAxisCount = visitorCounts.count - 10 //取最新的十筆
        }
        
        for i in xAxisCount..<visitorCounts.count {
            let timeIntervalForDate: TimeInterval = visitorCounts[i].date.timeIntervalSince1970
            //let stringFromCount = String(format: "%.2f", visitorCounts[i].count)
            let dataEntry = ChartDataEntry(
                x: Double(timeIntervalForDate),
                y: Double(visitorCounts[i].count))
            //let dataEntry = ChartDataEntry(x: Double(timeIntervalForDate), y: Double(stringFromCount)!)
            print("timeIntervalForDate = \(timeIntervalForDate)")
            print("visitorCounts[i].count = \(visitorCounts[i].count)")
            dataEntries.append(dataEntry)
        }
        

        
        lineView.rightAxis.enabled = false
        
        //let chartDataSet = BarChartDataSet(values: dataEntries, label: "Temperture")
        //let chartDataSet = LineChartDataSet(values: dataEntries,label: "Temperture")
        //let chartData = LineChartData(dataSet: chartDataSet)
        
        let lineChartDataSet = LineChartDataSet(values: dataEntries, label: "Temperture")
        lineChartDataSet.mode = .cubicBezier
        lineChartDataSet.drawCirclesEnabled = true //不畫外環
        lineChartDataSet.drawCircleHoleEnabled = true
        lineChartDataSet.circleRadius = 7
        lineChartDataSet.circleHoleRadius = 5
        lineChartDataSet.lineWidth = 5
        
        if (alertSwitchBool == true){
            let ll = ChartLimitLine(limit: Double(readUser())!, label: "Target")
            lineView.rightAxis.addLimitLine(ll)
        } else {
            lineView.rightAxis.removeAllLimitLines();
        }
        lineView.leftAxis.axisMinimum = 0 //左邊Ｙ軸的範圍
        lineView.leftAxis.axisMaximum = 40
        
        if (alertSwitchBool){
            let setTempture = Double(readUser())
            let celsiusValue:Double = Double(readUser())!
            if (celsiusValue < setTempture!){
                //fill gradient CYAN
                let gradientColors = [UIColor.cyan.cgColor, UIColor.clear.cgColor] as CFArray // Colors of the gradient
                let colorLocations:[CGFloat] = [1.0, 0.0] // Positioning of the gradient
                let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations) // Gradient Object
                lineChartDataSet.fill = Fill.fillWithLinearGradient(gradient!, angle: 90.0) // Set the Gradient
                lineChartDataSet.drawFilledEnabled = true // Draw the Gradient
                //
            } else {
                //fill gradient RED
                let gradientColors = [UIColor.red.cgColor, UIColor.clear.cgColor] as CFArray // Colors of the gradient
                let colorLocations:[CGFloat] = [1.0, 0.0] // Positioning of the gradient
                let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations) // Gradient Object
                lineChartDataSet.fill = Fill.fillWithLinearGradient(gradient!, angle: 90.0) // Set the Gradient
                lineChartDataSet.drawFilledEnabled = true // Draw the Gradient
                //
            }
        }
        
        
        let lineChartData = LineChartData(dataSet: lineChartDataSet)
        print( "lineChartData.entryCount  = \( lineChartData.entryCount )")
        
        if (lineChartData.entryCount > 0){
            lineView.data = lineChartData
            let xaxis = lineView.xAxis
            xaxis.valueFormatter = axisFormatDelegate
        }else{
            //資料量不足十筆
        }
    }
    
    func getVisitorCountsFromDatabase() -> Results<ChartsDatas> {
        do {
            let realm = try Realm()
            //print (realm.configuration.fileURL)
            //file:///var/mobile/Containers/Data/Application/5492A9DA-063A-483B-879D-10CCED749775/Documents/default.realm
            pickerValueUpdated()
            //獲取資料過濾器
            let predicate =
            "dateYYYYMMdd BEGINSWITH '\(dateString)' AND dateHHmmToInt > \(timeInt-2)"
            print("\(predicate)")
            //return realm.objects(ChartsDatas.self).filter(predicate)
            return realm.objects(ChartsDatas.self)
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    

    
    @IBAction func close(segue:UIStoryboardSegue){
        
    }
    
    //Connect to a Device
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if (peripheral.name != nil){
        print ("peripheral.name : \(peripheral.name)")
        print ("peripheral.id.uuid : \(peripheral.identifier.uuidString)")
        //if (peripheral.name == "Q Body C1"){
        if(peripheral.name == "Q Body C1"||peripheral.name == "Q Body C2"||peripheral.name == "Q Body C3"||peripheral.name == "Q Body C4"||peripheral.identifier.uuidString == "1CA8811B-234A-43CD-9D5D-8FBAA3040A56"){
            print("Name:\(peripheral.name)")
            tempertureDisplay.text = "發現裝置 " + peripheral.name!
            deviceName.isHidden = false
            deviceName.text = "裝置"+peripheral.name!+"連線中"
            //tempertureDisplay.text = "請重新連接..." //+ peripheral.name!
            self.qPeripheral = peripheral
            self.qPeripheral.delegate = self
            centralManager.stopScan()
            centralManager.connect(self.qPeripheral, options: nil)
            
        }
    }
    }
    
    //Get Characteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let servicePeripherals = peripheral.services as [CBService]!{
            for service in servicePeripherals{
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    //Setup notifications
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characterArray = service.characteristics as [CBCharacteristic]!{
            
            for cc in characterArray{
                if (cc.uuid.uuidString == "FFF4"){
                    peripheral.setNotifyValue(true, for: cc)
                    //peripheral.readValue(for: cc)
                    print("Find \(cc.uuid.uuidString)")
                }
            }
        }
    }
    
    //Changes Are Coming
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid.uuidString == "FFF4" {
            guard let data = characteristic.value else {
                return
            }
            //let dataString = String(data: data, encoding: String.Encoding.unicode)
            var uintData = [UInt8](repeating:0, count:data.count)
            data.copyBytes(to: &uintData, count: data.count)//解析data
            
            if (tempCount == 0){
                tempValue = UInt32(uintData[0])*256 //接收第一次byte, 乘以256(左移8bits)
                tempCount = 1
                //print ("count 0 -> Data = \(data)")
                //print ("count 0 -> uintData = \(uintData)")
                //print ("count 0 -> tempUInt8 = \(tempValue)")
            }else if (tempCount == 1){
                let temp: UInt32
                temp = UInt32(uintData[0])
                tempValue = tempValue + temp
                //print ("count 1 -> Data = \(data)")
                //print ("count 1 -> uintData = \(uintData)")
                print ("count 1 -> tempUInt8 = \(tempValue)") //tempValue為解析後ADC
                adctoCelsius(adcValue: tempValue)
                
                
                tempCount = 2
            }else{
                tempCount = 0 //電池量byte
            }
            //print ("uintData = \(uintData)")
            
        }
        
    }
    
    //ADC to Celsius
    func adctoCelsius(adcValue: UInt32){
        var voltageValue:Double = Double(tempValue)
        voltageValue = voltageValue/0.99/8191*1240
        
        let celsiusValue:Double = 211.1491 - voltageValue*0.1921
        let myString = String(format:"%.2f", celsiusValue)
        //celsiusValue = Double(myString)!
        
        tempertureDisplay.text = "目前溫度 : "+myString + "°C"
        print("目前溫度 : \(myString)  °C")
        let visitorCount = ChartsDatas()
        visitorCount.count = Double(myString)!
        print("visitorCount.count = \(visitorCount.count)")
        visitorCount.save()
        //tfValue.text = ""
        //tfValue.resignFirstResponder()
        //lineView.animate(xAxisDuration: 2, yAxisDuration: 2, easingOption: .easeInOutQuad)
        updateChartWithData()
        
        //let alertVC = AlertViewController()
        
//readUser()
        
        let setTempture = Double(readUser())
        print("setTempture is \(setTempture)")
        if (alertSwitchBool){
            if (celsiusValue > setTempture!){
                notificationSession(degree: myString, setTempture:setTempture!)
            }
        }
        
    }
    
    func readUser() -> String {
        var str:String = "25.0"
        if (UserDefaults.standard.object(forKey: "setValue") != nil) {
            str =  UserDefaults.standard.object(forKey: "setValue") as! String
            print("获取的本地话存储值\(str)")
        }
        return str
    }
    
    //Notification
    func notificationSession(degree: String, setTempture:Double){
        
        let content = UNMutableNotificationContent()
        content.title = "Tempture warning"
        content.subtitle = "Too hot"
        content.body = "How is \(degree) degrees, higher than \(setTempture) "
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let requestIdenrifier = "Quanta Computer"
        let request = UNNotificationRequest(identifier: requestIdenrifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler:
            { error in })
//        //通知名称常量
//        let NotifyChatMsgRecv = NSNotification.Name(rawValue:"notifyChatMsgRecv")
//        
//        
//        //发送通知
//        NotificationCenter.default.post(name:NotifyChatMsgRecv, object: nil, userInfo: notification.userInfo)
//        
//        //接受通知监听
//        NotificationCenter.default.addObserver(self, selector:#selector(didMsgRecv(notification:)), name: NotifyChatMsgRecv, object: nil)
    }

    //Get Services
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    
    //Scan for devices
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        var state:String = ""
        switch central.state {
        case .poweredOn:
            state = "Bluetooth on this device is currently powered on."
            // 1
            //keepScanning = true
            // 2
            //_ = NSTimer(timeInterval: timerScanInterval, target: self, selector: #selector(pauseScan), userInfo: nil, repeats: false)
            // 3
            tempertureDisplay.text = "尋找裝置中"
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        case .poweredOff:
            state = "Bluetooth on this device is currently powered off."
            tempertureDisplay.text = "請開啟藍芽"
        case .unsupported:
            state = "This device does not support Bluetooth Low Energy."
        case .unauthorized:
            state = "This app is not authorized to use Bluetooth Low Energy."
        case .resetting:
            state = "The BLE Manager is resetting; a state update is pending."
        case .unknown:
            state = "The state of the BLE Manager is unknown."
        }
        
        print("\(state)")
    }

    

}

// MARK: axisFormatDelegate
extension ViewController: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }
}

