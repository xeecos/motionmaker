//
//  CameraSettingCell.swift
//  GIFMaker
//
//  Created by indream on 15/9/20.
//  Copyright © 2015年 indream. All rights reserved.
//

import UIKit

class EndCameraSettingCell: UITableViewCell {
    
    @IBOutlet weak var focusLabel: UILabel!
    @IBOutlet weak var focusSlider: UISlider!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var speedSlider: UISlider!
    @IBOutlet weak var isoLabel: UILabel!
    @IBOutlet weak var isoSlider: UISlider!
    @IBOutlet weak var focusSwitcher: UISwitch!
    @IBOutlet weak var speedSwitcher: UISwitch!
    @IBOutlet weak var isoSwitcher: UISwitch!
    var cid:Int16 = 0
    var sid:Int16 = 0
    weak var tableView:UITableView!
    func setCameraIndex(sid:Int16, cid:Int16){
        self.cid = cid
        if(self.cid<0){
            self.cid = 0
        }
        self.sid = sid
        if(self.sid<0){
            self.sid = 0
        }
        updateConfig()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        updateConfig()
    }
    func updateConfig(){
        let cam:CameraModel? = DataManager.sharedManager().camera(sid,cid: cid)!
        if(cam==nil){
            DataManager.sharedManager().createCamera(sid,cid: cid)
        }
        let focus:Float = Float(cam!.focus)
        let speed:Float = Float(cam!.speed)
        if((focusSlider) != nil){
            focusSlider.value = focus
            focusLabel.text = String(format: "%.2f", focusSlider.value/8000.0)
            speedSlider.value = 0
            speedLabel.text = String(format: "1/%.0f", speed)
            isoSlider.value = Float(cam!.iso)
            isoLabel.text = String(format: "%.0f", isoSlider.value)
        }
        
    }
    func assignTableView(tableView:UITableView){
        self.tableView = tableView
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func focusChanged(sender: AnyObject) {
        focusLabel.text = String(format: "%.2f", focusSlider.value/8000.0)
        let cam:CameraModel = DataManager.sharedManager().camera(sid,cid: cid)!
        cam.focus = focusSlider.value
        tableView.alpha = 0.1
        VideoManager.sharedManager().configureDevice(sid,cid:cid)
    }
    
    @IBAction func speedChanged(sender: AnyObject) {
        let cam:CameraModel = DataManager.sharedManager().camera(sid,cid: cid)!
        var scale:Float = 1
        if(cam.speed<500){
            scale = 3
        }
        if(cam.speed<300){
            scale = 5
        }
        if(cam.speed<100){
            scale = 10
        }
        if(cam.speed<50){
            scale = 20
        }
        let speed = speedSlider.value/scale
        if(Float(cam.speed)+speed<2){
            speedLabel.text = String(format: "1/%d", 2)
        }else{
            speedLabel.text = String(format: "1/%.0f", Float(cam.speed)+speed)
        }
        tableView.alpha = 0.1
        VideoManager.sharedManager().configureDevice(sid,cid:cid)
    }
    
    @IBAction func speedTouchEnd(sender: AnyObject) {
        let cam:CameraModel = DataManager.sharedManager().camera(sid,cid: cid)!
        var scale:Float = 1
        if(cam.speed<500){
            scale = 3
        }
        if(cam.speed<300){
            scale = 5
        }
        if(cam.speed<100){
            scale = 10
        }
        if(cam.speed<50){
            scale = 20
        }
        cam.speed += Int16(speedSlider.value/scale)
        if(cam.speed<2){
            cam.speed = 2
        }else if(cam.speed>8000){
            cam.speed = 8000
        }
        speedLabel.text = String(format: "1/%d", cam.speed)
        speedSlider.value = 0
        tableView.alpha = 1.0
        speedSwitcher.on = false
        VideoManager.sharedManager().configureDevice(sid,cid:cid)
    }
    
    @IBAction func focusEnd(sender: AnyObject) {
        tableView.alpha = 1.0
        focusSwitcher.on = false
    }
    @IBAction func isoEnd(sender: AnyObject) {
        tableView.alpha = 1.0
        isoSwitcher.on = false
    }
    @IBAction func isoChanged(sender: AnyObject) {
        isoLabel.text = String(format: "%.0f", isoSlider.value)
        let cam:CameraModel = DataManager.sharedManager().camera(sid,cid: cid)!
        cam.iso = Int16(isoSlider.value)
        tableView.alpha = 0.1
        VideoManager.sharedManager().configureDevice(sid,cid:cid)
    }
    
    @IBAction func focusSwitch(sender: AnyObject) {
        if(focusSwitcher.on){
            let prevCam:CameraModel = DataManager.sharedManager().camera(sid,cid: cid-1)!
            let cam:CameraModel = DataManager.sharedManager().camera(sid,cid: cid)!
            cam.focus = prevCam.focus
            focusLabel.text = String(format: "%.2f", cam.focus/8000.0)
            focusSlider.value = cam.focus
        }
    }
    
    @IBAction func speedSwitch(sender: AnyObject) {
        if(speedSwitcher.on){
            let prevCam:CameraModel = DataManager.sharedManager().camera(sid,cid: cid-1)!
            let cam:CameraModel = DataManager.sharedManager().camera(sid,cid: cid)!
            cam.speed = prevCam.speed
            if(cam.speed<2){
                cam.speed = 2
            }else if(cam.speed>8000){
                cam.speed = 8000
            }
            speedLabel.text = String(format: "1/%d", cam.speed)
            speedSlider.value = 0
        }
    }
    
    @IBAction func isoSwitch(sender: AnyObject) {
        if(isoSwitcher.on){
            let prevCam:CameraModel = DataManager.sharedManager().camera(sid,cid: cid-1)!
            let cam:CameraModel = DataManager.sharedManager().camera(sid,cid: cid)!
            cam.iso = prevCam.iso
            isoSlider.value = Float(cam.iso)
            isoLabel.text = String(format: "%.0f", isoSlider.value)
        }
    }
}
