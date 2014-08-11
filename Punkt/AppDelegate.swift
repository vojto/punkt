//
//  AppDelegate.swift
//  Punkt
//
//  Created by Vojtech Rinik on 18/06/14.
//  Copyright (c) 2014 rinik. All rights reserved.
//

import Cocoa



class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet var window : NSWindow!
    
    override func awakeFromNib()  {
        MagicalRecord.setupCoreDataStack()
    }
    
    
    func applicationDidFinishLaunching(notification: NSNotification!) {
//        MagicalRecord.setupCoreDataStack()
    }
    
    func applicationWillTerminate(notification: NSNotification!) {
        MagicalRecord.cleanUp()
    }
    

}
