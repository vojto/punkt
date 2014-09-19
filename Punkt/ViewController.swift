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
    var client = GithubClient.sharedInstance
    var issues: [Issue]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        list.numberOfItems = 0
        list.itemAtIndex = self.boxForIssueAtIndex
    
        let tableView = list.view(view.bounds)
        view.addSubview(tableView)
        
        view.addConstraint("|[v]|", view: tableView)
        view.addConstraint("V:|[v]|", view: tableView)
        
        list.refresh()
    }
    
    func loadIssues() {
        client.loadIssues("vojto/punkt") { issues in
            println("Loaded issues: \(issues)")
            self.issues = issues
            self.list.numberOfItems = issues.count
            self.list.refresh()
        }
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
            "token_uri": "https://github.com/login/oauth/access_token",
        ]
        
        let oauth = OAuth2CodeGrant(settings: settings)
        oauth.onAuthorize = { parameters in
            println("Did authorize with parameters: \(parameters)")
            let params = parameters as [String:String]
            self.client.accessToken = params["access_token"]
            
            // TODO: Later we'll want something sophisticated, reactive with promises and shit
            self.loadIssues()
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
            oauth.handleRedirectURL($0)
        }
    }
    
    func boxForIssueAtIndex(index: Int) -> Box {
        let issue = self.issues![index]
        return self.boxForIssue(issue)
    }
    
    func boxForIssue(issue: Issue) -> Box {
        let issueTitle = issue.title!
        
        var container = ContainerBox()
        container.name = "container"
        container.backgroundColor = NSColor.blueColor()
        
        var numberWidth: Float = 60
        var padding: Float = 16
        
        var number = Box(width: numberWidth, height: 40)
        number.name = "number"
        number.backgroundColor = NSColor.whiteColor()
        number.text = "#" + issue.number!
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
        
        for label in issue.labels! {
            addLabel(label.name!, label.color!)
        }
        
        return container
    }


}

