//
//  Views.swift
//  Punkt
//
//  Created by Vojto2 on 27.6.2014.
//  Copyright (c) 2014 rinik. All rights reserved.
//

import Foundation

class BackgroundView: NSView {
    let background = NKColor(hex: "f8f8f8").color
    
    override func drawRect(dirtyRect: NSRect)  {
        background.setFill()
        NSRectFill(self.bounds)
    }
}



class HeaderView: NSTableHeaderView {
    let background = NKColor(hex: "yellow").color
}



