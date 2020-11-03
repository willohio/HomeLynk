//
//  NYRetsSearchEndpoint.swift
//  HomeLynk
//
//  Created by Ivan Dilchovski on 1/28/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation
import Alamofire


enum NYRetsSearchEndpoint: Endpoint
{	
	case Search(searchType: RetsSearchType, searchQuery: String, selectFields: String, limit: Int, index: Int)
	
	var baseURL: String {
		return Constants.URLStrings.nyRetsServer
	}
	
	var path : String {
		switch self
		{
			case .Search: return "/search"
		}
	}
	
	var method: Alamofire.Method {
		switch self
		{
			case .Search: return .GET
		}
	}
	
	var parameters: [String : AnyObject]? {
		switch self
		{
			case .Search(let searchType, let searchQuery, let selectFields, let limit, _):
				var parameters = [String : AnyObject]()
				parameters["Format"] = "COMPACT"
				parameters["QueryType"] = "DMQL2"

				parameters["Query"] = searchQuery
				parameters["Select"] = selectFields
				parameters["Limit"] = limit
				parameters["Count"] = 1
				
				switch searchType
				{
					case .Property:
						parameters["SearchType"] = "Property"
						parameters["Class"] = "LST"
					
					case .Agent:
						parameters["SearchType"] = "Agent"
						parameters["Class"] = "AGT"
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