//
//  File.swift
//  Punkt
//
//  Created by Vojtech Rinik on 9/19/14.
//  Copyright (c) 2014 Vojtech Rinik. All rights reserved.
//

import Foundation

class Issue: NSObject {
    var number: String?
    var title: String?
    var labels: [Label]?
    
    override init() {
        
    }
    
    func description() -> String {
        let labelsText = self.labels.map { $0.description }
        return "<Issue number=\(number) title=\(title) labels=[\(labelsText)]>"
    }
}

class Label: NSObject {
    var name: String?
    var color: String?
    
    func description() -> String {
        return "<Label name=\(name) color=\(color)>"
    }
}