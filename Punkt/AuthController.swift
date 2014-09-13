//
//  AuthController.swift
//  Punkt
//
//  Created by Vojtech Rinik on 9/13/14.
//  Copyright (c) 2014 Vojtech Rinik. All rights reserved.
//

import Cocoa
import WebKit

class AuthController: NSViewController {
    
    @IBOutlet var webView: WebView?
    
    var url: NSURL = NSURL(string: "about:blank") {
        didSet(value) {
            webView?.load(url)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        println("Loading url: \(url)")
        webView!.load(url)
        
    }

    
}
