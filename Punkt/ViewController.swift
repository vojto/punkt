//
//  ViewController.swift
//  Punkt
//
//  Created by Vojtech Rinik on 9/12/14.
//  Copyright (c) 2014 Vojtech Rinik. All rights reserved.
//

import Cocoa

let AuthRedirectURL = "http://rinik.net/punkt"

class ViewController: NSViewController {
    
    @IBOutlet var authController: NSViewController?
    var list = BoxList()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        

        // Do any additional setup after loading the view.
        
        let issues = [
            ("This line might be a little bit longer than usual, because I'm ai. trying to see if the lines break properly.", ["bar", "baz"]),
            ("And this one's short", ["bar", "baz"])
        ]
        
        list.numberOfItems = issues.count
        list.itemAtIndex = {
            return self.boxForIssue(issues[$0])
        }
    
        
        let tableView = list.view(view.bounds)
//        view.addSubview(tableView)
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    override func viewDidAppear() {
        let settings = [
            "client_id": "53eb5cf7707eb8ac57cc",
            "client_secret": "d480ae1eeca5a1fd2d5140f8262bab12cfd6ef06",
            "authorize_uri": "https://github.com/login/oauth/authorize",
            "token_uri": "wtf",
        ]
        
        let oauth = OAuth2CodeGrant(settings: settings)
        oauth.onAuthorize = { parameters in
            println("Did authorize with parameters: \(parameters)")
        }
        oauth.onFailure = { error in
            println("Authorization went wrong: \(error.localizedDescription)")
        }
        
        
        let url = oauth.authorizeURLWithRedirect(AuthRedirectURL, scope: "user,repo", params: nil)
        println("URL: \(url)")
        
        let authController = storyboard.instantiateControllerWithIdentifier("auth") as AuthController
        authController.url = url
        presentViewControllerAsModalWindow(authController)
        
        authController.onAuthorize = {
            println("Authorized - url = \($0)")
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
        title.padding.bottom = 4
        title.padding.right = 15
        content.add(title)
        
        var labels = Box()
        labels.breaksLine = true
        labels.name = "labels"
        //        labels.backgroundColor = NSColor.blueColor()
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

