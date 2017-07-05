//
//  AlertViewController.swift
//  tempertureBLE
//
//  Created by Jician.ho  on 2017/3/9.
//  Copyright © 2017年 JicianHo. All rights reserved.
//

import UIKit

class AlertViewController: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var integerPickerView: UIPickerView!
    @IBOutlet weak var decimalPickerView: UIPickerView!

    var integerArray = [Int](0...50)
    var decimalArray = [Int](0...9)
    var intString = "0"
    var decString = "0"
    var intRow = 28
    var decRow = 0
    var mainVC = ViewController()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        integerPickerView.delegate = self
        decimalPickerView.delegate = self
        integerPickerView.dataSource = self
        decimalPickerView.dataSource = self
        
        defaultPick()
    }
    

    func defaultPick(){

        print("integerArray is of type [Int] with \(integerArray.count) items.")
        
        intRow = readInt()
        decRow = readDec()
        
        integerPickerView.selectRow(intRow, inComponent: 0, animated: true)
        decimalPickerView.selectRow(decRow, inComponent: 0, animated: true)
//        var j = 0
//        for i in 20 ... 50{
//            integerArray[i-20] = i
//        }
//        j = 0
//        for i in stride(from:0, to:100, by:5){
//            decimalArray[j] = i
//            j = j + 1
//        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView == integerPickerView){
            return integerArray.count
        }else{
            return decimalArray.count
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView == integerPickerView){
                return String(integerArray[row])
            }
        else{
                return String(decimalArray[row])
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if (pickerView == integerPickerView){ //save integer
            intString = String(integerArray[row])
            mainVC.intString = intString
            intRow = row
            
        }else{ // save decimal
            decString = String(decimalArray[row])
            mainVC.decString = decString
            decRow = row
        }
        
        print("intString is \(intString), decString is \(decString)")
        print("mainVC.intString is \(mainVC.intString), mainVC.decString is \(mainVC.decString)")
        let sumString = self.intString + "." + self.decString
        userAction(str: sumString, int:intRow, dec:decRow)
    }
    
    func userAction(str :String, int :Int, dec:Int) -> Void {
        UserDefaults.standard.set(str, forKey: "setValue")
        UserDefaults.standard.set(intRow, forKey: "setValueInt")
        UserDefaults.standard.set(decRow, forKey: "setValueDec")
    }
    
    func readInt() -> Int {
        var int:Int = 0
        if (UserDefaults.standard.object(forKey: "setValueInt") != nil) {
            int =  UserDefaults.standard.object(forKey: "setValueInt") as! Int
            print("获取的本地话存储值\(int)")
        }
        return int
    }
    
    func readDec() -> Int {
        var int:Int = 0
        if (UserDefaults.standard.object(forKey: "setValueDec") != nil) {
            int =  UserDefaults.standard.object(forKey: "setValueDec") as! Int
            print("获取的本地话存储值\(int)")
        }
        return int
    }
    
//    func decimalPickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return decimalArray.count
//    }
//    func decimalPickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return String(decimalArray[row])
//    }
//    func decimalPickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        
//    }
    
}
