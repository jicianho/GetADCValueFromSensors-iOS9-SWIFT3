//
//  BLEScanTableViewController.swift
//  tempertureBLE
//
//  Created by Jician.ho  on 2017/2/10.
//  Copyright © 2017年 JicianHo. All rights reserved.
//

import UIKit
import CoreBluetooth

class BLEScanTableViewController: UITableViewController, CBCentralManagerDelegate, CBPeripheralDelegate{
    
    var members = [BLEMember]()
    var centralManager:CBCentralManager!
    var qPeripheral:CBPeripheral!
    var tempValue: UInt32 = 0
    var tempCount: Int = 0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        loadBLEMembers()
        
        self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
        
        //BLE
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        //print("\(qPeripheral.readRSSI())")
        
    }
    
    //Connect to a Device
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print ("peripheral.name : \(peripheral.name)")
        if (peripheral.name == "Q Body C2"){
            print("Name:\(peripheral.name)")
            self.qPeripheral = peripheral
            self.qPeripheral.delegate = self
            centralManager.stopScan()
            centralManager.connect(self.qPeripheral, options: nil)
            
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
                tempCount = 2
            }else{
                tempCount = 0 //電池量byte
            }
            //print ("uintData = \(uintData)")

        }

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
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        case .poweredOff:
            state = "Bluetooth on this device is currently powered off."
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
    

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }
    
    private func loadBLEMembers() {

        
        
        let member1 = BLEMember(rssi: 65, uuid: "testing ble 1")
        let member2 = BLEMember(rssi: 35, uuid: "testing ble 2")
        let member3 = BLEMember(rssi: 45, uuid: "testing ble 3")
        
        
        members += [member1, member2, member3]
    }
    

    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "BLEScanTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? BLEScanTableViewCell  else {
            fatalError("The dequeued cell is not an instance of BLEScanTableViewCell.")
        }

        let member = members[indexPath.row]
        
        let x : Int = member.rssi
        let myString = String(x)
        
        cell.readRSSI.text = myString
        cell.readUUID.text = member.uuid
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
