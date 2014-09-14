//
//  AuthController.swift
//  Punkt
//
//  Created by Vojtech Rinik on 9/13/14.
//  Copyright (c) 2014 Vojtech Rinik. All rights reserved.
//

import Cocoa
import WebKit
import Foundation

class AuthController: NSViewController {
    
    @IBOutlet var webView: WebView?
    
    var onAuthorize: (url: String) -> () = { _ in }
    var onDismiss: () -> () = { }
    
    var url: NSURL = NSURL(string: "about:blank") {
        didSet(value) {
            println("loading - \(url)")
            webView?.load(url)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Set up delegates
        webView!.frameLoadDelegate = self
        
        // Open the current URL
        println("loading - \(url)")
        webView!.load(url)
    }
    
    /*
- (void)webView:(WebView *)sender
didStartProvisionalLoadForFrame:(WebFrame *)frame
*/
    
    
    /*

- (void)webView:(WebView *)sender willPerformClientRedirectToURL:(NSURL *)URL delay:(NSTimeInterval)seconds fireDate:(NSDate *)date forFrame:(WebFrame *)frame

*/
    
    override func webView(sender: WebView!, willPerformClientRedirectToURL URL: NSURL!, delay seconds: NSTimeInterval, fireDate date: NSDate!, forFrame frame: WebFrame!) {
        println("redirecting to \(url)")
    }
    
    override func webView(sender: WebView!, didReceiveServerRedirectForProvisionalLoadForFrame frame: WebFrame!) {
        let url = frame.provisionalDataSource.request.URL!.absoluteString!
        if url.rangeOfString(AuthRedirectURL) != nil {
            println("All done!")
            onAuthorize(url: url)
        }
    }


    
}
