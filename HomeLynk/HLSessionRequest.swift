//
//  HLSessionRequest.swift
//  HomeLynk
//
//  Created by Ivan Dilchovski on 1/23/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation

import Alamofire
import SwiftyJSON

class HLSessionRequest: Request
{
	static func login(
		email email: String,
		password: String,
		successHandler success: ((user: HLUser) -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?) -> Alamofire.Request
	{
		let loginEndpoint = HLSessionEndpoint.Login(email: email, password: password)
		
		// TODO: Use generic user from JSON
		return makeRequestToEndpoint(loginEndpoint,
			withJSONResponseHandler: { (json) -> () in
				guard  json["session"].dictionary != nil
					else
				{
					failure?(error: .BadResponseFormat("Missing user from session JSON"))
					return
				}
				
				guard let _ = json["session"]["token"].string
					else
				{
					failure?(error: .BadResponseFormat("Missing auth token from session JSON"))
					return
				}
				
				guard let user = HLUser(json: json["session"])
					else
				{
					failure?(error: .BadResponseFormat("Could not parse user from JSON"))
					return
				}
				
				success?(user: user)
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
	
	static func verifyToken(
		token: String,
		email: String,
		successHandler success: ((user: HLUser) -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?) -> Alamofire.Request
	{
		let verifyToken = HLSessionEndpoint.LoginWithAuthToken
		return makeRequestToEndpoint(verifyToken,
			withJSONResponseHandler: { (json) -> () in
				guard let user = HLUser(json: json["session"])
					else
				{
					failure?(error: .BadResponseFormat("Could not parse user from JSON"))
					return
				}
				
				success?(user: user)
			}, failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
	
	static func logout(
		successHandler success: (() -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?) -> Alamofire.Request
	{
		let logoutEndpoint = HLSessionEndpoint.Logout
		return makeRequestToEndpoint(logoutEndpoint,
			withResponseHandler: { (_) -> () in
				success?()
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}

}