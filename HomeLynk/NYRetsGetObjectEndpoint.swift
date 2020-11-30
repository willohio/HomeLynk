//
//  NYRetsGetObjectEndpoint.swift
//  HomeLynk
//
//  Created by William Santiago on 1/30/16.
//  Copyright © 2016 William Santiago. All rights reserved.
//

import Foundation

import Alamofire

enum NYRetsGetObjectEndpoint: Endpoint
{
	case GetPictures(propertyIds: [Int], firstOnly: Bool)
	
	var baseURL: String {
		return Constants.URLStrings.nyRetsServer
	}
	
	var path : String {
		switch self
		{
			case .GetPictures: return "/getObject"
		}
	}
	
	var method: Alamofire.Method {
		switch self
		{
			case .GetPictures: return .GET
		}
	}
	
	var parameters: [String : AnyObject]? {
		
		switch self
		{
			case .GetPictures(let propertyIds, let firstOnly):
				var parameters = [String : AnyObject]()
				parameters["Type"] = "Photo"
				parameters["Resource"] = "Property"
				
				let photoIndex = firstOnly ? "0" : "*"
				var idString = ""
				for id in propertyIds
				{
					idString += "\(id):\(photoIndex),"
				}
				
				if idString != "" //Remove last comma
				{
					idString = idString.substringToIndex(idString.endIndex.predecessor())
				
					parameters["ID"] = idString
				}
				
			
				return parameters
		}
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
