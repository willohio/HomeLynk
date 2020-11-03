//
//  OauthEndpoint.swift
//  HomeLynk
//
//  Created by Ivan Dilchovski on 1/23/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation

import Alamofire

enum OauthEndpoint: Endpoint
{
	case AccessToken(clientId: String, clientSecret: String)
	
	var baseURL: String {
		return Constants.URLStrings.retsRabbit
	}
	
	var path : String {
		switch self
		{
			case AccessToken(_): return "/oauth/access_token"
		}
	}
	
	var method: Alamofire.Method {
		switch self
		{
			case .AccessToken(_): return .POST
		}
	}
	
	var parameters: [String : AnyObject]? {
		switch self
		{
			case .AccessToken(let clientId, let clientSecret):
				return ["grant_type" : "client_credentials",
					"client_id" : clientId,
					"client_secret" : clientSecret,
					"scope": "scope1"]
		}
	}
	
	var encoding: Alamofire.ParameterEncoding {
		switch self
		{
			default: return .URLEncodedInURL
		}
	}
	
	var headers: [String : String]? {
		return nil
	}
}