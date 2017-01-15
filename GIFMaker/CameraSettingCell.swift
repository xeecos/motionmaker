//
//  CameraSettingCell.swift
//  GIFMaker
//
//  Created by indream on 15/9/20.
//  Copyright © 2015年 indream. All rights reserved.
//

import UIKit

class CameraSettingCell: UITableViewCell {

    @IBOutlet weak var focusLabel: UILabel!
    @IBOutlet weak var focusSlider: UISlider!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var speedSlider: UISlider!
    @IBOutlet weak var isoLabel: UILabel!
    @IBOutlet weak var isoSlider: UISlider!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var intervalLabel: UILabel!
    @IBOutlet weak var intervalSlider: UISlider!
    var cid:Int16 = 0
    var sid:Int16 = 0
    weak var tableView:UITableView!
    func setCameraIndex(_ sid:Int16, cid:Int16){
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
        if((timeSlider) != nil){
            timeSlider.value = 0
            timeLabel.text = String(format: "%d %@", cam!.time,NSLocalizedString("secs", comment: ""))
            
            intervalSlider.value = 0
            intervalLabel.text = String(format: "%.1f %@ / %d %@", cam!.interval,NSLocalizedString("secs", comment: ""),Int(Float(cam!.time)/Float(cam!.interval)),NSLocalizedString("frames", comment: ""))
        }

    }
    func assignTableView(_ tableView:UITableView){
        self.tableView = tableView
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func focusChanged(_ sender: AnyObject) {
        focusLabel.text = String(format: "%.2f", focusSlider.value/8000.0)
        let cam:CameraModel = DataManager.sharedManager().camera(sid,cid: cid)!
        cam.focus = focusSlider.value
        tableView.alpha = 0.1
        VideoManager.sharedManager().configureDevice(sid,cid:cid)
    }
    
    @IBAction func speedChanged(_ sender: AnyObject) {
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
    
    @IBAction func speedTouchEnd(_ sender: AnyObject) {
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
        VideoManager.sharedManager().configureDevice(sid,cid:cid)
    }
    
    @IBAction func focusEnd(_ sender: AnyObject) {
        tableView.alpha = 1.0
    }
    @IBAction func isoEnd(_ sender: AnyObject) {
        tableView.alpha = 1.0
    }
    @IBAction func isoChanged(_ sender: AnyObject) {
        isoLabel.text = String(format: "%.0f", isoSlider.value)
        let cam:CameraModel = DataManager.sharedManager().camera(sid,cid: cid)!
        cam.iso = Int16(isoSlider.value)
        tableView.alpha = 0.1
        VideoManager.sharedManager().configureDevice(sid,cid:cid)
    }
    @IBAction func timeChanged(_ sender: AnyObject) {
        let cam:CameraModel = DataManager.sharedManager().camera(sid,cid: cid)!
        let time = timeSlider.value/2
        
        timeLabel.text = String(format: "%.1f %@", Float(cam.time)+time,NSLocalizedString("secs", comment: ""))
        intervalLabel.text = String(format: "%.1f %@ / %d %@", cam.interval,NSLocalizedString("secs", comment: ""),Int((Float(cam.time)+time)/cam.interval),NSLocalizedString("frames", comment: ""))
    }
    @IBAction func timeTouchEnd(_ sender: AnyObject) {
        let cam:CameraModel = DataManager.sharedManager().camera(sid,cid: cid)!
        cam.time += Int32(floorf(timeSlider.value/2))
        if(cam.time<0){
            cam.time = 0
        }
        timeSlider.value = 0
        timeLabel.text = String(format: "%.1f %@", Float(cam.time),NSLocalizedString("secs", comment: ""))
        intervalLabel.text = String(format: "%.1f %@ / %d %@", cam.interval,NSLocalizedString("secs", comment: ""),Int((Float(cam.time)/cam.interval)),NSLocalizedString("frames", comment: ""))
    }
    
    @IBAction func intervalChanged(_ sender: AnyObject) {
        let cam:CameraModel = DataManager.sharedManager().camera(sid,cid: cid)!
        let interval = intervalSlider.value/4
        if((cam.interval+interval)>0.1){
            intervalLabel.text = String(format: "%.1f %@ / %d %@", (cam.interval+interval),NSLocalizedString("secs", comment: ""),Int(Float(cam.time)/Float(cam.interval+interval)),NSLocalizedString("frames", comment: ""))
        }else{
            intervalLabel.text = String(format: "%.1f %@ / %d %@",0.1,NSLocalizedString("secs", comment: ""),Int(Float(cam.time)/0.1),NSLocalizedString("frames", comment: ""))
        }
    }
    
    @IBAction func intervalTouchEnd(_ sender: AnyObject) {
        let cam:CameraModel = DataManager.sharedManager().camera(sid,cid: cid)!
        cam.interval += intervalSlider.value/4
        if(cam.interval<0.1){
            cam.interval = 0.1
        }
        intervalSlider.value = 0
        timeLabel.text = String(format: "%.1f %@", Float(cam.time),NSLocalizedString("secs", comment: ""))
        intervalLabel.text = String(format: "%.1f %@ / %d %@", cam.interval,NSLocalizedString("secs", comment: ""),Int((Float(cam.time)/cam.interval)),NSLocalizedString("frames", comment: ""))
    }
}
