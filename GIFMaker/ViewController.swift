//
//  ViewController.swift
//  GIFMaker
//
//  Created by indream on 15/9/17.
//  Copyright © 2015年 indream. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var videoView:UIView?
    @IBOutlet weak var recordButton: UIBarButtonItem!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let c:CameraModel? = DataManager.sharedManager().camera(0)
        if((c) != nil){
            print("focus:\((c?.speed)!)")
        }else{
            DataManager.sharedManager().createSetting()
            DataManager.sharedManager().createCamera(0,cid:0)
            DataManager.sharedManager().createCamera(0,cid:1)
            DataManager.sharedManager().save()
            
            print("init data")
        }
        // Do any additional setup after loading the view, typically from a nib.
        
        VideoManager.sharedManager().initSession();
        
        recordButton.title = NSLocalizedString("Record", comment: "")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "disableRecord", name: "STOP_RECORDING", object: nil)
    }
    override func viewWillAppear(animated: Bool) {
        print("appear")
        VideoManager.sharedManager().configVideoView(self.videoView!)
        VideoManager.sharedManager().configureDevice(0,cid:0)
    }
    @IBAction func openSetting(sender: AnyObject) {
        self.presentViewController(SettingViewController(), animated: true) { () -> Void in
            
        }
    }
    let screenWidth = UIScreen.mainScreen().bounds.size.width
   
    
    var recording:Bool = false
    var disableButton:Bool = false
    @IBAction func switchRecord(sender: AnyObject) {
        if(disableButton){
            let time: NSTimeInterval = 2.0
            let delay = dispatch_time(DISPATCH_TIME_NOW,Int64(time * Double(NSEC_PER_SEC)))
            dispatch_after(delay, dispatch_get_main_queue()) {
                self.disableButton = false
            }
            return
        }
        disableButton = true
        let item:UIBarButtonItem = sender as! UIBarButtonItem
        recording = !recording
        if(recording){
            item.title = NSLocalizedString("Stop", comment: "")
            startRecord()
            
        }else{
            item.title = NSLocalizedString("Record", comment: "")
            stopRecord()
        }
    }
    
    func disableRecord(){
        print("disableRecord")
        recording = false
        recordButton.title = NSLocalizedString("Record", comment: "")
        let alert:UIAlertView? = UIAlertView(title: "Tip", message: NSLocalizedString("The video is saved into Photo Album \"Motion Maker\"",comment:""), delegate: nil, cancelButtonTitle: "OK")
        alert?.show()
        
    }
    
    func startRecord() {
        VideoManager.sharedManager().recordBarButton = self.recordButton
        VideoManager.sharedManager().startRecord()
        
    }
    func stopRecord() {
        VideoManager.sharedManager().stopRecord()
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.LandscapeRight;
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prefersStatusBarHidden() -> Bool {
        return false;
    }
}

