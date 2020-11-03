//
//  HLUserRequest.swift
//  HomeLynk
//
//  Created by Ivan Dilchovski on 1/23/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation

import Alamofire
import SwiftyJSON

class HLUserRequests: Request
{
	// MARK: - Public requests
	
	static func createNewUser(
		user: HLUser,
		password: String,
		passwordConfirmation: String,
		successHandler success: ((user: HLUser) -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?) -> Alamofire.Request
	{
		let createUserEndpoint = HLUserEndpoint.CreateUser(user: user, password: password, passwordConfirm: passwordConfirmation)
		
		return makeRequestToEndpoint(createUserEndpoint,
			withJSONResponseHandler: { (json) -> () in
				if let user = HLUser(json: json["user"])
				{
					success?(user: user)
				} else
				{
					log.error("Could not get user from JSON response")
					failure?(error: RequestError.BadResponseFormat("Could not get user from JSON response"))
				}
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
	
	static func updateUser(
		user: HLUser,
		password: String?,
		passwordConfirmation: String?,
		successHandler success: ((user: HLUser) -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?) -> Alamofire.Request
	{
		let updateUserEndpoint = HLUserEndpoint.UpdateUser(user, password, passwordConfirmation)
		
		return makeRequestToEndpoint(updateUserEndpoint,
			withJSONResponseHandler: { (json) -> () in
				if let user = HLUser(json: json["user"])
				{
					success?(user: user)
				} else
				{
					log.error("Could not get user from JSON response")
					failure?(error: RequestError.BadResponseFormat("Could not get user from JSON response"))
				}
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
}