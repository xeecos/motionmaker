//
//  CameraModel.swift
//  GIFMaker
//
//  Created by indream on 15/9/20.
//  Copyright © 2015年 indream. All rights reserved.
//

import UIKit
import CoreData
class CameraModel: NSManagedObject {
    
    @NSManaged var cid: Int16
    @NSManaged var focus: Float
    @NSManaged var speed: Int16
    @NSManaged var iso: Int16
    @NSManaged var aperture: Float
    @NSManaged var time: Int32
    @NSManaged var interval: Float
    @NSManaged var index: Int16
    @NSManaged var sid: Int16
    
    class func create(context: NSManagedObjectContext) -> CameraModel {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Camera", inManagedObjectContext: context) as! CameraModel
        return newItem
    }
}
