//
//  HLSessionEndpoint.swift
//  HomeLynk
//
//  Created by Ivan Dilchovski on 1/23/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation
import Alamofire

enum HLSessionEndpoint: Endpoint
{
	case Login(email: String, password: String)
	case LoginWithAuthToken
	case Logout
	
	case BustaTest
	
	var baseURL: String {
		return Constants.URLStrings.homeLynkServer
	}
	
	var path : String {
		switch self
		{
			case .Login(_): return "/sessions"
			case .LoginWithAuthToken: return "/sessions/login_with_token"
			
			case .Logout:	return "/sessions/logout"
			
			case .BustaTest:	return "/sessions/busta_test"
		}
	}
	
	var method: Alamofire.Method {
		switch self
		{
			case .Login(_): return .POST
			case .LoginWithAuthToken: return .GET
			
			case .Logout: return .GET
			case .BustaTest: return .GET
		}
	}
	
	var parameters: [String : AnyObject]? {
		switch self
		{
			case .Login(let email, let password):
				var params = [String : Dictionary<String, AnyObject>]()
				params = ["session" :	["email" : email,
					"password" : password,
					"platform" : Constants.Values.PlatformString]]
				
				if let deviceToken = Settings.Device.pushToken
				{
					params["session"]!["device_token"] = deviceToken
				} else
				{
					log.info("???")
				}
				
				return params
				
			case .LoginWithAuthToken:
				if let deviceToken = Settings.Device.pushToken
				{
					return ["platform" : Constants.Values.PlatformString,
						"device_token" : deviceToken]
				} else
				{
					return ["platform" : Constants.Values.PlatformString]
				}
				
				
			case .Logout:
				if let deviceToken = Settings.Device.pushToken
				{
					return ["device_token" : deviceToken]
				} else
				{
					return nil
				}
			
			default: return nil
		}
	}
	
	var encoding: Alamofire.ParameterEncoding {
		switch self
		{
			case .LoginWithAuthToken, .Logout: return .URLEncodedInURL
			default: return .JSON
		}
	}
	
	var headers: [String : String]? {
		var headers = [String : String]()
		
		switch self
		{
			default:
				headers["Accept"] = "application/json"
		}
		
		switch self
		{
			case .LoginWithAuthToken, .Logout:
				if let (email, token) = authTokenAndMail
				{
					let authHeader = "Token token=\"\(token)\", email=\"\(email)\""
					headers["Authorization"] = authHeader
				}
			default: ()
		}
		
		return headers
	}
}