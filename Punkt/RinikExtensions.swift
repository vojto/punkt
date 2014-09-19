//
//  RinikExtensions.swift
//  Punkt
//
//  Created by Vojtech Rinik on 9/13/14.
//  Copyright (c) 2014 Vojtech Rinik. All rights reserved.
//

import Foundation
import WebKit

extension NSViewController {
    func presentViewControllerWithIdentifierAsSheet(identifier: String) {
        let controller = storyboard.instantiateControllerWithIdentifier(identifier) as NSViewController
        presentViewControllerAsSheet(controller)
    }
}

extension WebView {
    func load(url: NSURL) {
        self.mainFrame.loadRequest(NSURLRequest(URL: url))
    }
}

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