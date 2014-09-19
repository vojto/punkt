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
    
    var onAuthorize: ((url: NSURL) -> ())?
    var onDismiss: () -> () = { }
    
    var url: NSURL = NSURL(string: "about:blank")! {
        didSet(value) {
            webView?.load(url)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Set up delegates
        webView!.frameLoadDelegate = self
        
        // Open the current URL
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
    }
    
    override func webView(sender: WebView!, didReceiveServerRedirectForProvisionalLoadForFrame frame: WebFrame!) {
        let url = frame.provisionalDataSource.request.URL!
        let urlString = url.absoluteString!
        if urlString.rangeOfString(AuthRedirectURL) != nil {
            onAuthorize?(url: url)
        }
        
        self.dismissViewController(self)
    }


    
}
