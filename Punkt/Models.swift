//
//  Models.swift
//  Punkt
//
//  Created by Vojto2 on 27.6.2014.
//  Copyright (c) 2014 rinik. All rights reserved.
//

import Foundation

// Models

class Issue: NSObject {
    var id: Int
    var title: String
    var labels: [String]
    var url: String
    
    init(title: String, labels: [String], url: String, id: Int) {
        self.title = title
        self.labels = labels
        self.url = url
        self.id = id
    }
    
    func description() -> String {
        return "<\(title) [\(labels)]>"
    }
    
    func removeLabel(label: String) {
        let index = $.findIndex(labels) { $0 == label }
        if index != nil {
            labels.removeAtIndex(index!)
        }
    }
    
    func addLabel(label: String) {
        if label != "*" {
            labels.append(label)
        }
    }
}