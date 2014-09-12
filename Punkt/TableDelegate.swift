//
//  TableDelegate.swift
//  Punkt
//
//  Created by Vojtech Rinik on 9/12/14.
//  Copyright (c) 2014 Vojtech Rinik. All rights reserved.
//

import Foundation
import Cocoa

class BoxList: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    var numberOfItems: Int
    
    var cachedBoxes: [Int:Box] = [:]
    
    override init() {
        self.numberOfItems = 3
        
        self.itemAtIndex = {
            var box = Box()
            box.outerHeight = ($0 == 0) ? 20 : 50
            box.backgroundColor = NSColor.redColor()
            return box
        }
    }
    
    var itemAtIndex: (index: Int) -> Box?
    
    func numberOfRowsInTableView(tableView: NSTableView!) -> Int {
        return self.numberOfItems
    }
    
    func tableView(tableView: NSTableView!, heightOfRow row: Int) -> CGFloat {
        var box = self.boxAtIndex(row)
        print("box at index \(row) is \(box)")
        return CGFloat(box.outerHeight)
    }
    
    func boxAtIndex(index: Int) -> Box {
        if let box = self.cachedBoxes[index] {
            return box
        }
        
        let box = self.itemAtIndex(index: index)!
        
        self.cachedBoxes[index] = box
        
        return box
    }
    

}