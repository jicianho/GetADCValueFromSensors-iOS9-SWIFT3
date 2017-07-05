//
//  ChartsDatas.swift
//  tempertureBLE
//
//  Created by Jician.ho  on 2017/2/21.
//  Copyright © 2017年 JicianHo. All rights reserved.
//

import Foundation
import RealmSwift

class ChartsDatas: Object {
    dynamic var date: Date = Date()
    let dateYYYYMMddFormat = DateFormatter()
    let dateHHmmFormat = DateFormatter()
    
    
    dynamic var dateYYYYMMdd: String = "20000101"
    dynamic var dateHHmm: String = "0000"
    dynamic var dateHHmmToInt: Int = 0
    dynamic var count: Double = Double(0.0)

    func dateLongToShort(orgDate:Date!){
        dateYYYYMMddFormat.dateFormat = "YYYYMMdd"
        dateYYYYMMdd = dateYYYYMMddFormat.string(from: orgDate)

        dateHHmmFormat.dateFormat = "HHmm"
        dateHHmm = dateHHmmFormat.string(from: orgDate)
        
        dateHHmmToInt = Int(dateHHmm)!

        print("\(date)")
        print("\(dateYYYYMMdd)")
        print("\(dateHHmmToInt)")
    }
    func save() {
        dateLongToShort(orgDate: date)
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(self)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    override static func indexedProperties() -> [String] {
        return ["date"]
    }

}

