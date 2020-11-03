//
//  OauthRequest.swift
//  HomeLynk
//
//  Created by Ivan Dilchovski on 1/23/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation

import Alamofire
import SwiftyJSON

class OauthRequest: Request
{
	static func requestAccessToken(clientId clientId: String, clientSecret: String, success: ((accessToken: String) -> ())?, failureHandler failure: ((error: RequestError) -> ())?)
	{
		let oauthEndpoint = OauthEndpoint.AccessToken(clientId: clientId, clientSecret: clientSecret)
		makeRequestToEndpoint(oauthEndpoint,
			withJSONResponseHandler: { (json) -> () in
				if let accessToken = json["access_token"].string
				{
					success?(accessToken: accessToken)
				} else
				{
					failure?(error: RequestError.BadResponseFormat("Access token not found in response"))
				}
			}, failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
	
}