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
    
    @IBAction func switchRecord(sender: AnyObject) {
        let item:UIBarButtonItem = sender as! UIBarButtonItem
        recording = !recording
        if(recording){
            item.title = "Stop"
            startRecord()
        }else{
            item.title = "Record"
            stopRecord()
        }
    }
    
    func disableRecord(){
        print("disableRecord")
        recording = false
        recordButton.title = "Record"
        let alert:UIAlertView? = UIAlertView(title: "Tip", message: "The video is saved into Photo Album \"Motion Maker\"", delegate: nil, cancelButtonTitle: "OK")
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
        return UIInterfaceOrientationMask.Landscape;
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prefersStatusBarHidden() -> Bool {
        return false;
    }
}

