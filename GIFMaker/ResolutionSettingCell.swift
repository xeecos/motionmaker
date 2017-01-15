//
//  ResolutionSettingCell.swift
//  GIFMaker
//
//  Created by indream on 15/9/20.
//  Copyright © 2015年 indream. All rights reserved.
//

import UIKit

class ResolutionSettingCell: UITableViewCell {

    @IBOutlet weak var resolutionSeg: UISegmentedControl!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let setting:SettingModel = DataManager.sharedManager().setting(0)!
        resolutionSeg.selectedSegmentIndex = Int(setting.resolution)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func resolutionChanged(_ sender: AnyObject) {
        
        let sw:UISegmentedControl = sender as! UISegmentedControl
        let setting:SettingModel = DataManager.sharedManager().setting(0)!
        setting.resolution = Int16(sw.selectedSegmentIndex)

    }
}
