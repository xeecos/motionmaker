//
//  ModeSettingCell.swift
//  GIFMaker
//
//  Created by indream on 15/9/20.
//  Copyright © 2015年 indream. All rights reserved.
//

import UIKit

class ModeSettingCell: UITableViewCell {

    @IBOutlet weak var modeSeg: UISegmentedControl!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let setting:SettingModel = DataManager.sharedManager().setting(0)!
        modeSeg.selectedSegmentIndex = Int(setting.mode)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func modeChanged(_ sender: AnyObject) {
        let sw:UISegmentedControl = sender as! UISegmentedControl
        let setting:SettingModel = DataManager.sharedManager().setting(0)!
        setting.mode = Int16(sw.selectedSegmentIndex)

    }
}
