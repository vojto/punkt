//
//  ViewController.swift
//  Punkt
//
//  Created by Vojtech Rinik on 9/12/14.
//  Copyright (c) 2014 Vojtech Rinik. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    var list = BoxList()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let issues = [
            ("Meet Marka", ["bar", "baz"]),
            ("Ask her out on a date", ["bar", "baz"])
        ]
        
        list.numberOfItems = issues.count
        list.itemAtIndex = {
            return self.boxForIssue(issues[$0])
        }
    
        
        let tableView = list.view(view.bounds)
        view.addSubview(tableView)
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func boxForIssue(issue: (String, [String])) -> Box {
        let (issueTitle, issueLabels) = issue
        
        var container = Box()
        
        var numberWidth: Float = 60
        var padding: Float = 16
        
        var number = Box(width: numberWidth, height: 40)
        number.name = "number"
        number.backgroundColor = NSColor.whiteColor()
        number.text = "#605"
        number.textColor = NSColor(hex: "c4c4c4")
        number.padding.all = padding
        number.font = NSFont.boldSystemFontOfSize(12)
        number.position.left = 0
        container.add(number)
        
        var content = Box()
        content.name = "content"
        //        content.backgroundColor = NSColor.redColor()
        content.position.left = numberWidth
        content.position.right = 0
        //        content.padding.all = padding
        container.add(content)
        
        var title = Box(text: issueTitle)
        title.name = "title"
        title.font = NSFont.boldSystemFontOfSize(13)
        title.padding.top = 8
        //        title.backgroundColor = NSColor.yellowColor()
        content.add(title)
        
        var labels = Box()
        labels.name = "labels"
        //        labels.backgroundColor = NSColor.blueColor()
        labels.position.left = 0
        labels.position.right = 0
        labels.position.top = 30
        content.add(labels)
        
        func addLabel(text: String, color: String) {
            var label = Box(text: text)
            label.font = NSFont.boldSystemFontOfSize(11)
            label.backgroundColor = NSColor(hex: color)
            label.textColor = NSColor.whiteColor()
            label.margin.right = 5
            label.margin.bottom = 5
            label.padding.left = 2
            label.padding.right = 2
            labels.add(label)
        }
        
        for label in issueLabels {
            addLabel(label, "0052cc")
        }
        
        return container
    }


}

