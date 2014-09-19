//
//  BoxKit.swift
//  BoxKit
//
//  Created by Vojtech Rinik on 29/08/14.
//  Copyright (c) 2014 rinik. All rights reserved.
//

import Foundation
import Cocoa

class BKView : NSView {
    var box: Box?
    
    var outerBounds: NSRect {
        get {
            var bounds = self.bounds
            var margin = self.box!.margin

            return margin.reduceBounds(bounds)
        }
    }
    
    var innerBounds: NSRect {
        get {
            var bounds = self.outerBounds
            var padding = self.box!.padding
            
            return padding.reduceBounds(bounds)
        }
    }
    
    override var flipped: Bool {
        get {
            return true
        }
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    override func drawRect(dirtyRect: NSRect) {
        let backgroundColor = self.box!.backgroundColor
        
        backgroundColor.set()
        NSRectFill(self.outerBounds)
        
        if let text = self.box?.text {
            let string = NSString(string: text)
            string.drawInRect(self.innerBounds, withAttributes: box!.textAttributes())
        }
    }

}

struct Position {
    var top: Float?
    var right: Float?
    var bottom: Float?
    var left: Float?
    
    var all: Float {
        get {
            return top!
        }
        set(value) {
            top = value
            right = value
            bottom = value
            left = value
        }
    }
    
    var width: Float {
        get {
            var width: Float = 0
            width += (left != nil) ? left! : 0
            width += (right != nil) ? right! : 0
            return width
        }
    }
    
    var height: Float {
        get {
            return top! + bottom!
        }
    }
    
    var hasHorizontal: Bool {
        get {
            return left != nil && right != nil
        }
    }
    
    var hasVertical: Bool {
        get {
            return top != nil && bottom != nil
        }
    }
    
    init() {
        
    }
    
    init(initial: Float) {
        self.top = 0
        self.right = 0
        self.bottom = 0
        self.left = 0
    }
    
    func reduceBounds(bounds: NSRect) -> NSRect {
        var bounds = bounds // make a copy
        bounds.origin.x += CGFloat(left!)
        bounds.origin.y += CGFloat(top!)
        bounds.size.width -= CGFloat(width)
        bounds.size.height -= CGFloat(height)
        return bounds
    }
}

class Box : NSObject {
    var name: String?
    
    private var width: Float?
    private var height: Float?
    var breaksLine = false
    
    private var childrenWidth: Float = 0
    private var childrenHeight: Float = 0
    
    var top: Float = 0
    var left: Float = 0
    var isLaidOut: Bool = false
    var children: Array<Box> = []
    var cachedView: NSView?
    
    var text: String?
    var font: NSFont = NSFont.systemFontOfSize(20)
    
    var backgroundColor = NSColor.whiteColor()
    var textColor = NSColor.blackColor()
    
    var margin: Position = Position(initial: 0)
    var padding: Position = Position(initial: 0)
    var position: Position = Position()
    
    var isAbsolute: Bool {
        get {
            return position.left != nil || position.top != nil
        }
    }
    
    var hasWidth: Bool {
        get {
            return self.width != nil
        }
    }
    
    var hasHeight: Bool {
        get {
            return self.height != nil
        }
    }
    
    var outerWidth: Float {
        get {
            if let w = width {
                return w + margin.width + padding.width
            } else {
                return margin.width + padding.width
            }
        }
        
        set(value) {
            self.width = value - margin.width - padding.width
        }
    }
    
    var outerHeight: Float {
        get {
            if let h = height {
                return h + margin.height + padding.height
            } else {
                return margin.height + padding.height
            }
            
        }
        
        set(value) {
            self.height = value - margin.height - padding.height
        }
    }
    
    var innerWidth: Float {
        get {
            return width!
        }
        set(value) {
            self.width = value
        }
    }
    
    var innerHeight: Float {
        get {
            return height!
        }
        set(value) {
            self.height = value
        }
    }
    
    override init() {
        
    }
    
    init(width: Float, height: Float) {
        super.init()
        self.outerWidth = width
        self.outerHeight = height
    }
    
    init(width: Float) {
        super.init()
        self.outerWidth = width
    }
    
    init(width: Float, height: Float, text: String) {
        super.init()
        self.outerWidth = width
        self.outerHeight = height
        self.text = text
    }
    
    init(height: Float, text: String) {
        super.init()
        self.outerHeight = height
        self.text = text
    }
    
    init(text: String) {
        self.text = text
    }
    
    func description() -> String {
        return "<Box width=\(width) height=\(height) top=\(top) left=\(left) children=\(children.count)>"
    }
    
    func add(child: Box) {
        self.children.append(child)
    }
    
    func layout() {
        layout(nil)
    }
    
    func layout(parent: Box?) {
        if isLaidOut {
            return
        }
        
        // Reality check
        if self.text != nil && self.children.count > 0 {
            NSException(name: "cannot layout", reason: "box can't have both children and text", userInfo: nil).raise()
        }
        

        // Try to compute dimensions based on text
        self.computeDimensionsFromText(parent)
        
        // Layout children inside this box
        var top: Float = 0
        var left: Float = 0
        var rowHeight: Float = 0
        var containerWidth: Float
        
        if let w = self.width {
            containerWidth = w
        } else {
            containerWidth = Float(Int.max)
        }
        
        var rowWidths: [Float] = []
        var lastHeight: Float = 0
        var lastChild: Box?
        
        // Layout all fluid children
        for var i = 0; i < children.count; i++ {
            var child = children[i]
            
            if child.isAbsolute {
                continue
            }
            
            // Call layout on the child to make sure it gets its 
            // width set.
            child.layout(self)
            
            if child.outerHeight > rowHeight {
                rowHeight = child.outerHeight
                if rowHeight > lastHeight {
                    lastHeight = rowHeight
                }
            }
            
            // New line
            if child.breaksLine || (containerWidth - left) < child.outerWidth {
                rowWidths.append(left + child.outerWidth)
                
                top += rowHeight
                left = 0
                rowHeight = 0
                
                lastHeight = child.outerHeight
            }
            
            // Insert child at top,left
            child.top = top
            child.left = left
            
            left += child.outerWidth
            
            lastChild = child
        }
        
        var totalHeight = top + lastHeight

        // Layout all absolute children
        var absoluteChildrenHeight: Float = 0

        for var i = 0; i < children.count; i++ {
            var child = children[i]
            
            if !child.isAbsolute {
                continue
            }
            
            // First, compute child's dimensions from its position
            if let positionLeft = child.position.left {
                child.left = positionLeft
            }
            
            // Before laying out, try to set width based on its absolute position
            if child.position.hasHorizontal {
                child.outerWidth = self.width! - child.position.left! - child.position.right!
            }
            
            if child.position.hasVertical {
                child.outerHeight = self.height! - child.position.top! - child.position.bottom!
            }
            
            child.layout(self)
            
            // After laying out, set position based on its dimensions and absolute position
            
            let left = child.position.left
            let right = child.position.right
            let top = child.position.top
            let bottom = child.position.bottom
            
            if right != nil && left == nil {
                child.left = self.width! - child.width! - right!
            } else if left != nil {
                child.left = left!
            }
            
            if bottom != nil && top == nil {
                child.top = self.height! - child.height! - bottom!
            } else if top != nil {
                child.top = top!
            }
            
            var childHeight = child.top + child.height!
            if childHeight > absoluteChildrenHeight {
                absoluteChildrenHeight = childHeight
            }
        }
        

        if absoluteChildrenHeight > totalHeight {
            totalHeight = absoluteChildrenHeight
        }
        
        var totalWidth: Float?
        if lastChild != nil {
            rowWidths.append(left + lastChild!.outerWidth)
        }
        if rowWidths.count > 0 {
            totalWidth = $.max(rowWidths)
        } else {
            totalWidth = 0
        }
        childrenWidth = totalWidth!
        childrenHeight = totalHeight
        
        self.computeDimensionsFromChildren()
        
        self.isLaidOut = true
    }
    
    func computeDimensionsFromChildren() {
//        println("Going to compute dimensions from children \((self.width, self.height)) \((self.childrenWidth, self.childrenHeight)) \(self.text)")
        
        if width == nil && self.childrenWidth > 0 {
            self.width = self.childrenWidth
        }
        
        if height == nil && self.childrenHeight > 0 {
            self.height = self.childrenHeight
        }
        
        
//        println("    result is \((self.width, self.height))")
    }
    
    func computeDimensionsFromText(parent: Box?) {
        if self.width != nil && self.height != nil {
            return
        }
        if self.text == nil {
            return
        }
        
        var string = NSString(string: self.text!)
        
        var availableWidth, availableHeight: Float
        
        if self.width != nil {
            availableWidth = self.width!
        } else if parent != nil && parent!.width != nil {
            availableWidth = parent!.width! - padding.width
        } else {
            availableWidth = Float(Int.max)
        }
        
//        println("Available width for text label: width=\(width) parent width=\(parent?.width) available=\(availableWidth)")
        
        availableHeight = self.height != nil ? self.height! : Float(Int.max)
        var availableSize = CGSize(width: CGFloat(availableWidth), height: CGFloat(availableHeight))
        
        var size = string.boundingRectWithSize(availableSize, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: self.textAttributes())
        
//        println("Dimensions computed for text \(text): \(size)")

        self.width = Float(ceil(size.width))
        self.height = Float(ceil(size.height))

    
    }
    
    func textAttributes() -> [NSObject : AnyObject]? {
        return [
            NSFontAttributeName: self.font,
            NSForegroundColorAttributeName: self.textColor
        ]
    }
    
    // Converts box hierarchy to view hierarchy
    func view() -> NSView {
        if  !isLaidOut {
            NSException(name: "BoxNotLaidOut", reason: "Box isn't laid out yet", userInfo: nil).raise()
        }
        
        if let cached = cachedView {
            return cached
        }
        
        var w: Float
        var h: Float
        
        if width != nil {
            w = outerWidth
        } else {
            w = 0
        }

        if height != nil {
            h = outerHeight
        } else {
            h = 0
        }
        
        let frame = NSMakeRect(CGFloat(left), CGFloat(top), CGFloat(w), CGFloat(h))
        let view = BKView(frame: frame)
        view.box = self
        
        for child in children {
            let childView = child.view()
            view.addSubview(childView)
        }
        
        self.cachedView = view
        
        return view
    }
}