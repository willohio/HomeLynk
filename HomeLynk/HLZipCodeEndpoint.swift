//
//  HLZipCodeEndpoint.swift
//  HomeLynk
//
//  Created by William Santiago on 2/25/16.
//  Copyright © 2016 William Santiago. All rights reserved.
//

import UIKit
import Alamofire

enum HLZipCodeEndpoint: Endpoint
{
	case FindZipInGeoRect(upperLeft: CGPoint, lowerRight: CGPoint)
	
	var baseURL: String
	{
		return Constants.URLStrings.homeLynkServer
	}
	
	var path : String
	{
		switch self
		{
			case .FindZipInGeoRect: return "/zip_codes/find_zip_within_bounds"
		}
	}
	
	var method: Alamofire.Method
	{
		switch self
		{
			case .FindZipInGeoRect: return .GET
		}
	}
	
	var parameters: [String : AnyObject]?
	{
		switch self
		{
			case .FindZipInGeoRect(let upperLeft, let lowerRight):
				return ["lat_upper_left" : upperLeft.x,
						"lat_lower_right" : lowerRight.x,
						"long_upper_left" : upperLeft.y,
						"long_lower_right" : lowerRight.y]
		}
	}
	
	var encoding: Alamofire.ParameterEncoding
	{
		switch self
		{
			case .FindZipInGeoRect: return .URLEncodedInURL
		}
	}
	
	var headers: [String : String]?
	{
		var headers = [String : String]()
		
		switch self
		{
			default:
				headers["Accept"] = "application/json"
		}
		
		switch self
		{
			default:
				if let (email, token) = authTokenAndMail
				{
					let authHeader = "Token token=\"\(token)\", email=\"\(email)\""
					headers["Authorization"] = authHeader
				}
		}
		
		return headers
	}
}
