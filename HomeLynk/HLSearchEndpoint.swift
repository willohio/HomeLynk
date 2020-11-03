//
//  HLSearchEndpoint.swift
//  HomeLynk
//
//  Created by Ivan Dilchovski on 2/2/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation

import Alamofire

enum HLSearchEndpoint: Endpoint
{
	case SaveSearch(search: HLSearch)
	case GetSavedSearches
	case Update(search: HLSearch)
	case DeleteSearch(search: HLSearch) //Search MUST have a valid id
	
	var baseURL: String {
		return Constants.URLStrings.homeLynkServer
	}
	
	var path : String {
		switch self
		{
			case .SaveSearch: return "/searches"
			case .GetSavedSearches: return "/searches"
			case .Update(let search):	return "/searches/\(search.id!)"
			case .DeleteSearch(let search): return "/searches/\(search.id!)"
		}
	}
	
	var method: Alamofire.Method {
		switch self
		{
			case .SaveSearch: return .POST
			case .GetSavedSearches: return .GET
			case .Update:	return .PUT
			case .DeleteSearch: return .DELETE
		}
	}
	
	var parameters: [String : AnyObject]? {
		switch self
		{
			case .SaveSearch(let search): return makeParametersFromSearch(search)
			case .Update(let search): return makeParametersFromSearch(search)
			
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
			default:
				if let (email, token) = authTokenAndMail
				{
					let authHeader = "Token token=\"\(token)\", email=\"\(email)\""
					headers["Authorization"] = authHeader
				}
		}
		
		return headers
	}
	
	private func makeParametersFromSearch(search: HLSearch) -> [String : AnyObject]
	{
		var searchDict = [String : AnyObject]()
		
		if let searchTitle = search.title
		{
			searchDict["title"] = searchTitle
			
			if let city = search.address?.city
			{
				searchDict["city"] = city
			}
			
			if let beds = search.minBeds
			{
				searchDict["beds"] = beds
			}
			
			if let baths = search.minBaths
			{
				searchDict["baths"] = baths
			}
			
			if let minPrice = search.minPrice
			{
				searchDict["min_price"] = minPrice
			}
			
			if let maxPrice = search.maxPrice
			{
				searchDict["max_price"] = maxPrice
			}
		} else
		{
			var title = ""
			
			if let city = search.address?.city
			{
				title += city
				title += ", "
				
				searchDict["city"] = city
			} else
			{
				title += "Anywhere, "
			}
			
			if let beds = search.minBeds
			{
				title += "\(beds)+"
				
				searchDict["beds"] = beds
			} else
			{
				title += "any"
			}
			
			title += "/"
			
			if let baths = search.minBaths
			{
				title += "\(baths)+"
				
				searchDict["baths"] = baths
			} else
			{
				title += "any"
			}
			
			title += ", "
			
			if let minPrice = search.minPrice
			{
				title += "$" + minPrice.suffixString() + "-"
				
				searchDict["min_price"] = minPrice
			} else
			{
				title += "$0-"
			}
			
			if let maxPrice = search.maxPrice
			{
				title += "$" + maxPrice.suffixString()
				
				searchDict["max_price"] = maxPrice
			}
			
			searchDict["title"] = title
		}
		
		searchDict["is_busta"] = search.isBlockBusta
		
		if let listingType = search.listingType
		{
			searchDict["search_type"] = listingType.rawValue
		}
		
		if let propertyType = search.propertyType
		{
			searchDict["property_type"] = propertyType.rawValue
		}
		
		if let minSqFt = search.minSqFt
		{
			searchDict["min_sqft"] = minSqFt
		}
		
		if let minLot = search.minLot
		{
			searchDict["min_lot"] = minLot
		}
		
		if let minYear = search.minYear
		{
			searchDict["min_year"] = minYear
		}
		
		if let listingAge = search.listingAge
		{
			searchDict["listing_age"] = listingAge.rawValue
		}
		
		if let zips = search.zips
		{
			searchDict["zips"] = zips
		} else
		{
			if let state = search.address?.state
			{
				searchDict["state"] = state
			}
			
			if let county = search.address?.county
			{
				searchDict["county"] = county
			}
			
			if let city = search.address?.city
			{
				searchDict["city"] = city
			}
			
			if let zip = search.address?.zip
			{
				searchDict["zip"] = zip
			}
		}
		
		if let savedOn = search.savedOn
		{
			searchDict["saved_on"] = savedOn
		}
		
		searchDict["search_query"] = NYRetsProvider.buildDQMLQueryFromSearch(search)
		
		return searchDict
	}
}