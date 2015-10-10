//
//  SettingViewController.swift
//  GIFMaker
//
//  Created by indream on 15/9/20.
//  Copyright © 2015年 indream. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.text = NSLocalizedString("Setting", comment: "")
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(animated: Bool) {
        if((self.videoView)==nil){
            
        }else{
            VideoManager.sharedManager().configVideoView(self.videoView!)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backHandle(sender: AnyObject) {
        DataManager.sharedManager().save()
        self.dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func focusSwitch(sender: AnyObject) {
    }
    @IBAction func addCameraHandle(sender: AnyObject) {
        DataManager.sharedManager().createCamera(0,cid:DataManager.sharedManager().countOfCamera(0));
        self.tableView.reloadData()
    }
    @IBAction func removeCameraHandle(sender: AnyObject) {
        let count:Int16 = DataManager.sharedManager().countOfCamera(0)
        if(count>2){
            DataManager.sharedManager().removeCamera(0,cid:count-1);
            self.tableView.reloadData()
        }
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title:String?
        switch(section){
        case 0:
            title = NSLocalizedString("Mode", comment: "")
            break
        case 1:
            title = NSLocalizedString("Resolution", comment: "")
            break
        case 2:
            title = NSLocalizedString("Start", comment: "")
            break
        default:
            break
        }
        if(section==tableView.numberOfSections-1){
            title = NSLocalizedString("Add", comment: "")
        }else if(section==tableView.numberOfSections-2){
            title = NSLocalizedString("End", comment: "")
        }else if(section>2){
            title = "# \(section-2)"
        }
        return title
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSectionsInTableView(tableView: UITableView) ->Int
    {
        return Int(DataManager.sharedManager().countOfCamera(0))+3
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height:CGFloat = 44.0
        let section:NSInteger = indexPath.section

        if(section==tableView.numberOfSections-2){
            height = 196
        }else if(section==tableView.numberOfSections-1){
            height = 44
        }else if(section>1){
            height = 300
        }else{
            height = 44
        }
        return height
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        let section = indexPath.section

        switch(section){
            case 0:
                cell = tableView.dequeueReusableCellWithIdentifier("modeSettingCell")
                if(cell==nil){
                    let _nib:NSArray = NSBundle.mainBundle().loadNibNamed("SettingCells", owner: self, options: nil)
                    cell = _nib.objectAtIndex(0) as? UITableViewCell;
                }
            break
            case 1:
                cell = tableView.dequeueReusableCellWithIdentifier("resolutionSettingCell")
                if(cell==nil){
                    let _nib:NSArray = NSBundle.mainBundle().loadNibNamed("SettingCells", owner: self, options: nil)
                    cell = _nib.objectAtIndex(1) as? UITableViewCell;
                }
                break
            default: break
        }
        if(section==tableView.numberOfSections-1){
            cell = tableView.dequeueReusableCellWithIdentifier("addSettingCell")
            if(cell==nil){
                let _nib:NSArray = NSBundle.mainBundle().loadNibNamed("SettingCells", owner: self, options: nil)
                cell = _nib.objectAtIndex(4) as? UITableViewCell;
            }
        }else if(section==tableView.numberOfSections-2){
            cell = tableView.dequeueReusableCellWithIdentifier("endSettingCell")
            if(cell==nil){
                let _nib:NSArray = NSBundle.mainBundle().loadNibNamed("SettingCells", owner: self, options: nil)
                cell = _nib.objectAtIndex(3) as? UITableViewCell;
            }
            (cell as! EndCameraSettingCell).setCameraIndex(0, cid: Int16(indexPath.section-2))
            (cell as! EndCameraSettingCell).assignTableView(self.tableView)
        }else if(section>1){
            cell = tableView.dequeueReusableCellWithIdentifier("cameraSettingCell")
            if(cell==nil){
                let _nib:NSArray = NSBundle.mainBundle().loadNibNamed("SettingCells", owner: self, options: nil)
                cell = _nib.objectAtIndex(2) as? UITableViewCell;
            }
            (cell as! CameraSettingCell).setCameraIndex(0, cid: Int16(indexPath.section-2))
            (cell as! CameraSettingCell).assignTableView(self.tableView)
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.LandscapeRight;
    }

    override func prefersStatusBarHidden() -> Bool {
        return false;
    }
}
