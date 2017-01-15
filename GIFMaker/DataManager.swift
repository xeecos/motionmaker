//
//  DataManager.swift
//  GIFMaker
//
//  Created by indream on 15/9/20.
//  Copyright © 2015年 indream. All rights reserved.
//

import UIKit
import CoreData
class DataManager: NSObject {
    
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    static let VIDEO_MODE:Int16 = 0
    static let TIMELASPE_MODE:Int16 = 1
    static let RESOLUTION_720P:Int16 = 0
    static let RESOLUTION_1080P:Int16 = 1
    static let RESOLUTION_2160P:Int16 = 2
    
    static var _instance:DataManager?
    
    static func sharedManager()->DataManager{
        if(_instance==nil){
            _instance = DataManager()
        }
        return _instance!
    }
    func createSetting()->SettingModel{
        let setting = SettingModel.create(self.managedObjectContext)
        setting.mode = DataManager.VIDEO_MODE
        setting.resolution = DataManager.RESOLUTION_720P
        setting.sid = 0
        setting.desc = "Default"

        return setting
    }
    func createCamera(_ sid:Int16,cid:Int16=0)->CameraModel{
        let cam = CameraModel.create(self.managedObjectContext)
        cam.sid = sid
        cam.focus = 10.0
        cam.speed = 100
        cam.aperture = 1.0
        cam.iso = 100
        cam.time = 10
        cam.interval = 0.1
        cam.cid = cid
        return cam
    }
    func removeCamera(_ sid:Int16,cid:Int16){
        let cam:CameraModel? = camera(sid, cid: cid)
        if((cam) != nil){
            managedObjectContext.delete(cam!)
        }
    }
    func setting(_ sid:Int16)->SettingModel?{
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Setting")
        request.predicate = NSPredicate(format: "sid == %d",sid)
        var result:NSArray! = []
        do {
            result = try managedObjectContext.fetch(request) as NSArray!
        } catch let error as NSError {
            print("error:\(error)")
        }
        if((result?.count)!>0){
            return result?[0] as? SettingModel
        }else{
            return nil
        }
    }
    func camera(_ sid:Int16,cid:Int16=0)->CameraModel?{
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Camera")
        request.predicate = NSPredicate(format: "sid == %d AND cid == %d",sid,cid)
        var result:NSArray! = []
        do {
            result = try managedObjectContext.fetch(request) as NSArray!
        } catch let error as NSError {
            print("error:\(error)")
        }
        if(result.count>0){
            return result[0] as? CameraModel
        }else{
            return nil
        }
    }
    func countOfCamera(_ sid:Int16)->Int16{
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Camera")
        request.predicate = NSPredicate(format: "sid == %d",sid)
        var result:NSArray! = []
        do {
            result = try managedObjectContext.fetch(request) as NSArray!
        } catch let error as NSError {
            print("error:\(error)")
        }
        return Int16(result.count)
    }
    func save()->Bool{
        do {
            try managedObjectContext.save()
        }catch let error as NSError {
            print(error)
            return false
        }
        return true
    }
}
