//
//  NYRetsLoginEndpoint.swift
//  HomeLynk
//
//  Created by Ivan Dilchovski on 1/27/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation

import Alamofire

enum NYRetsLoginEndpoint: Endpoint
{
	case Login
	
	var baseURL: String {
		return Constants.URLStrings.nyRetsServer
	}
	
	var path : String {
		switch self
		{
			case .Login: return "/login"
		}
	}
	
	var method: Alamofire.Method {
		switch self
		{
			case .Login: return .GET
		}
	}
	
	var parameters: [String : AnyObject]? {
		return nil
	}
	
	var encoding: Alamofire.ParameterEncoding {
		switch self
		{
			default: return .URLEncodedInURL
		}
	}
	
	var headers: [String : String]? {
		let headers = [
			"RETS-Version": "RETS/1.5",
			"User-Agent": "HomeLynk"
		]
		
		return headers
	}
}