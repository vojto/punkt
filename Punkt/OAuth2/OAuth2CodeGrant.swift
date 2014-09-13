//
//  OAuth2CodeGrant.swift
//  OAuth2
//
//  Created by Pascal Pfiffner on 6/16/14.
//  Copyright (c) 2014 Pascal Pfiffner. All rights reserved.
//

import Foundation


/**
 *  A class to handle authorization for confidential clients via the authorization code grant method.
 *
 *  This auth flow is designed for clients that are capable of protecting their client secret, which a distributed Mac/iOS App **is not**!
 */
public class OAuth2CodeGrant: OAuth2 {
	
	/** The URL string where we can exchange a code for a token; if nil `authURL` will be used. */
	public let tokenURL: NSURL?
	
	/** The receiver's long-time refresh token. */
	public var refreshToken = ""
	
	public override init(settings: NSDictionary) {
		if let token = settings["token_uri"] as? String {
			tokenURL = NSURL(string: token)
		}
		
		super.init(settings: settings)
	}
	
	
	override public func authorizeURLWithRedirect(redirect: String?, scope: String?, params: [String: String]?) -> NSURL {
		return authorizeURL(authURL!, redirect: redirect, scope: scope, responseType: "code", params: params)
	}
	
	public func tokenURLWithRedirect(redirect: String?, code: String, params: [String: String]?) -> NSURL {
		let base = tokenURL ?? authURL!
		var prms = ["code": code, "grant_type": "authorization_code"]
		if nil != clientSecret {
			prms["client_secret"] = clientSecret!
		}
		
		if nil != params {
			prms.addEntries(params!)
		}
		
		return authorizeURL(base, redirect: redirect, scope: nil, responseType: nil, params: prms)
	}
	
	/**
	 *  Create a request for token exchange
	 */
	public func tokenRequest(code: String) -> NSURLRequest {
		let url = tokenURLWithRedirect(redirect, code: code, params: nil)
		let comp = NSURLComponents(URL: url, resolvingAgainstBaseURL: true)
		let body = comp.query
		comp.query = nil
		
		let post = NSMutableURLRequest(URL: comp.URL!)
		post.HTTPMethod = "POST"
		post.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
		post.HTTPBody = body?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
		
		return post
	}
	
	/**
	 *  Extracts the code from the redirect URL and exchanges it for a token.
	 */
	override public func handleRedirectURL(redirect: NSURL) {
		logIfVerbose("Handling redirect URL \(redirect.description)")
		
		let (code, error) = validateRedirectURL(redirect)
		if nil != error {
			didFail(error)
		}
		else {
			exchangeCodeForToken(code!)
		}
	}
	
	/**
	 *  Takes the received code and exchanges it for a token.
	 */
	func exchangeCodeForToken(code: String) {
		
		// do we have a code?
		if (code.isEmpty) {
			didFail(genOAuth2Error("I don't have a code to exchange, let the user authorize first", .PrerequisiteFailed))
			logIfVerbose("No code to exchange for a token, cannot continue")
			return;
		}
		
		let post = tokenRequest(code)
		logIfVerbose("Exchanging code \(code) with redirect \(redirect!) for token at \(post.URL.description)")
		
		// perform the exchange
		let session = NSURLSession.sharedSession()
		let task = session.dataTaskWithRequest(post) { data, response, error in
			var finalError: NSError?
			
			if nil != error {
				finalError = error
			}
			else if nil != response && nil != data {
				if let http = response as? NSHTTPURLResponse {
					if 200 == http.statusCode {
						if let json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &finalError) as? NSDictionary {
							if let access = json["access_token"] as? String {
								self.accessToken = access
							}
							if let refresh = json["refresh_token"] as? String {
								self.refreshToken = refresh
							}
							
							self.logIfVerbose("Did receive access token: \(self.accessToken), refresh token: \(self.refreshToken)")
							self.didAuthorize(json)
							return
						}
					}
					else {
						finalError = genOAuth2Error(http.statusString, .AuthorizationError)
					}
				}
			}
			
			// if we're still here an error must have happened
			if nil == finalError {
				finalError = genOAuth2Error("Unknown connection error for response \(response) with data \(data)", .NetworkError)
			}
			
			self.didFail(finalError)
		}
		task.resume()
	}
	
	
	// MARK: - Utilities
	
	/**
	 *  Validates the redirect URI: returns a tuple with the code and nil on success, nil and an error on failure.
	 */
	func validateRedirectURL(redirect: NSURL) -> (code: String?, error: NSError?) {
		var code: String?
		var error: NSError?
		
		let comp = NSURLComponents(URL: redirect, resolvingAgainstBaseURL: true)
		if nil != comp.query && countElements(comp.query!) > 0 {
			let query = OAuth2CodeGrant.paramsFromQuery(comp.query!)
			if let cd = query["code"] {
				
				// we got a code, use it if state is correct (and reset state)
				if let st = query["state"] {
					if st == state {
						code = cd
						state = ""
					}
					else {
						error = genOAuth2Error("Invalid state \(st), will not use the code", .InvalidState)
					}
				}
				else {
					error = genOAuth2Error("No state was returned", .InvalidState)
				}
			}
			else {
				error = OAuth2CodeGrant.errorForAccessTokenErrorResponse(query)
			}
		}
		else {
			error = genOAuth2Error("The redirect URL contains no query fragment", .PrerequisiteFailed)
		}
		
		if nil != error {
			logIfVerbose("Invalid redirect URL: \(error!.localizedDescription)")
		}
		else {
			logIfVerbose("Successfully validated redirect URL")
		}
		return (code, error)
	}
}

