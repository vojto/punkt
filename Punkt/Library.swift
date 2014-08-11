//
//  Library.swift
//  Punkt
//
//  Created by Vojto2 on 27.6.2014.
//  Copyright (c) 2014 rinik. All rights reserved.
//

import Foundation
import Cocoa



extension NSView {
    func addConstraint(format: NSString, views: Dictionary<String, NSView>) {
        let constraints = NSLayoutConstraint.constraintsWithVisualFormat(format, options: nil, metrics: nil, views: views)
        self.addConstraints(constraints)
    }
    
    func addConstraint(format: NSString, view: NSView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(format, views: ["v": view])
    }
}

class Label: NSTextField {
//    override init(frame: NSRect) {
//        super.init(frame: frame)
//        
//        self.bezeled = false
//        self.drawsBackground = false
//        self.editable = false
//    }
}