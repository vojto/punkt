//
//  LabelPicker.swift
//  Punkt
//
//  Created by Vojto2 on 27.6.2014.
//  Copyright (c) 2014 rinik. All rights reserved.
//

import Cocoa

class LabelPicker: NSViewController {
    
    @IBOutlet var popover : NSPopover?
    var item: AnyObject?

    @IBAction func save(sender : AnyObject) {
//        println("Saving: \(column?.labelName)")
        NSManagedObjectContext.MR_contextForCurrentThread().MR_saveToPersistentStoreAndWait()
        popover!.close()
    }
}
