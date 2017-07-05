//
//  BLEScanTableViewCell.swift
//  tempertureBLE
//
//  Created by Jician.ho  on 2017/2/9.
//  Copyright © 2017年 JicianHo. All rights reserved.
//

import UIKit

class BLEScanTableViewCell: UITableViewCell {
    @IBOutlet weak var readRSSI: UILabel!
    @IBOutlet weak var readUUID: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }


}
