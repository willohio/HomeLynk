//
//  NYRetsLoginRequest.swift
//  HomeLynk
//
//  Created by Ivan Dilchovski on 1/28/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation

import Alamofire

class NYRetsLoginRequest: Request
{
	static func login(
		username username: String,
		password: String,
		successHandler success: (() -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?) -> Alamofire.Request
	{
		return makeAuthenticatedRequestToEndpoint(
			NYRetsLoginEndpoint.Login,
			username: username,
			password: password,
			successHandler: { () -> () in
				success?()
			}, failureHandler: { (error) -> () in
				failure?(error: error)
		})
	}
}