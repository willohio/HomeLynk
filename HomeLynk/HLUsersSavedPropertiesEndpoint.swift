//
//  HLUsersSavedPropertiesEndpoint.swift
//  HomeLynk
//
//  Created by Ivan Dilchovski on 2/2/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation

import Alamofire

enum HLUsersSavedPropertiesEndpoint: Endpoint
{
	case AddSavedProperty(propertyMlsid: Int)
	case GetSavedProperties
	case DeleteSavedProperty(propertyMlsid: Int)
	
	var baseURL: String {
		return Constants.URLStrings.homeLynkServer
	}
	
	var path : String {
		switch self
		{
			case .AddSavedProperty: return "/saved_properties"
			case .GetSavedProperties: return "/saved_properties"
			case .DeleteSavedProperty(let mlsid): return "/saved_properties/\(mlsid)"
		}
	}
	
	var method: Alamofire.Method {
		switch self
		{
			case .AddSavedProperty: return .POST
			case .GetSavedProperties: return .GET
			case .DeleteSavedProperty: return .DELETE
		}
	}
	
	var parameters: [String : AnyObject]? {
		switch self
		{
			case .AddSavedProperty(let mlsid):
				return ["saved_property" :	["property_mlsid" : mlsid]]
			
			default:
				return nil
		}
	}
	
	var encoding: Alamofire.ParameterEncoding {
		switch self
		{
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
			case .AddSavedProperty, GetSavedProperties, DeleteSavedProperty:
				if let (email, token) = authTokenAndMail
				{
					let authHeader = "Token token=\"\(token)\", email=\"\(email)\""
					headers["Authorization"] = authHeader
				}
		}
		
		return headers
	}
}