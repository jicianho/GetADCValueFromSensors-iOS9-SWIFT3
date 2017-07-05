//
//  BLEAdapter.swift
//  tempertureBLE
//BLEMember.swift
//  Created by Jician.ho  on 2017/2/10.
//  Copyright © 2017年 JicianHo. All rights reserved.
//

import UIKit

class BLEMember {
    
    //MARK: Properties
    
    var rssi: Int
    var uuid: String
    
    init (rssi:Int, uuid:String){
        // Initialize stored properties.
        self.rssi = rssi
        self.uuid = uuid
    }
}




