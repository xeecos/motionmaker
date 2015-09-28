//
//  SettingModel.swift
//  GIFMaker
//
//  Created by indream on 15/9/20.
//  Copyright © 2015年 indream. All rights reserved.
//

import UIKit
import CoreData

class SettingModel: NSManagedObject {
    @NSManaged var desc:String
    @NSManaged var mode:Int16
    @NSManaged var resolution:Int16
    @NSManaged var sid:Int16
    
    class func create(context: NSManagedObjectContext) -> SettingModel {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Setting", inManagedObjectContext: context) as! SettingModel
        return newItem
    }
}
