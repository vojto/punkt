//
//  GithubClient.swift
//  Punkt
//
//  Created by Vojtech Rinik on 9/19/14.
//  Copyright (c) 2014 Vojtech Rinik. All rights reserved.
//

import Alamofire

private let _GithubClientSharedInstance = GithubClient()

class GithubClient  {
    var accessToken: String? {
        didSet {

        }
    }
    
    init() {
        
    }
    
    class var sharedInstance : GithubClient {
        return _GithubClientSharedInstance
    }
    
    func loadIssues(repo: String, done: ([Issue]) -> ()) {
        let url = "/repos/\(repo)/issues"
        self.load(url) { data in
            let array = data as NSArray as Array
            let issues: [Issue] = array.map { item in
                let dict = item as [String:AnyObject]
                
                let issue = Issue()
                println("item: \(item)")
                let number = item["number"] as Int
                issue.number = "\(number)"
                issue.title = item["title"] as? String
                
                let labels = item["labels"] as NSArray as Array
                issue.labels = labels.map { item in
                    let label = Label()
                    label.name = item["name"] as? String
                    label.color = item["color"] as? String
                    return label
                }
                
                return issue
            }
            
            done(issues)
        }
    }
    
    func load(path: String, done: (AnyObject) -> ()) {
        let url = "https://api.github.com\(path)"
        
        println("Loading: \(url)")
        
        var params: [String:String] = [:]
        
        params["access_token"] = accessToken
        params["per_page"] = "1"

        println("Params: \(params)")
        
        Alamofire.request(.GET, url, parameters: params).responseJSON { (_, response, json, _) in
            done(json!)
        }
    }
}