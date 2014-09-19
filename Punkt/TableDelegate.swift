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
    var tableView: NSTableView?
    
    var cachedBoxes: [Int:Box] = [:]
    
    override init() {
        self.numberOfItems = 3
    }
    
    var itemAtIndex: (index: Int) -> Box? = { _ in
        return nil
    }
    
    func numberOfRowsInTableView(tableView: NSTableView!) -> Int {
        return self.numberOfItems
    }
    
    func tableView(tableView: NSTableView!, heightOfRow row: Int) -> CGFloat {
        var box = self.boxAtIndex(row)
        box.givenWidth = Float(tableView.bounds.size.width)
        box.layout()
        return CGFloat(box.outerHeight)
    }
    
    func tableView(tableView: NSTableView!, viewForTableColumn tableColumn: NSTableColumn!, row: Int) -> NSView! {
        let width = tableColumn.width
        println("Getting view for row \(row) - column width \(width)")
        
        var box = self.boxAtIndex(row)
//        box.outerWidth = Float(width)
        
        return box.view()
    }
    
    func boxAtIndex(index: Int) -> Box {
        if let box = self.cachedBoxes[index] {
            return box
        }
        
        let box = self.itemAtIndex(index: index)!
        
        self.cachedBoxes[index] = box
        
        return box
    }
    
    func view(frame: NSRect) -> NSView {
        let scrollView = NSScrollView(frame: frame)
        // should it be bigger than the scroll view?
        self.tableView = NSTableView(frame: frame)
        
        let column = NSTableColumn(identifier: "column")
        column.width = frame.size.width
        
//        println("Setting delegate/data source to: \(self)")
        
        tableView!.addTableColumn(column)
        tableView!.setDelegate(self)
        tableView!.setDataSource(self)
        
        tableView!.allowsColumnReordering = false
        tableView!.allowsColumnResizing = false
        tableView!.allowsColumnSelection = false
        tableView!.headerView = nil
        
        tableView!.gridStyleMask = NSTableViewGridLineStyle.SolidHorizontalGridLineMask;
        
        scrollView.documentView = tableView
        scrollView.hasVerticalScroller = true // needed?
        
        return scrollView
    }
    
    func refresh() {
        tableView!.reloadData()
    }
    

}