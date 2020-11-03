//
//  HLSearch+JSON.swift
//  HomeLynk
//
//  Created by Ivan Dilchovski on 2/2/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation

import SwiftyJSON

extension HLSearch
{
	//TODO: ObjectMapper?
	class func getSearchFromJSON(json: JSON) -> HLSearch?
	{
		guard let id = json["id"].int
			else
		{
			log.error("No ID for search from server")
			return nil
		}
		
		let search = HLSearch()
		search.id = id
		
		if let searchTypeRaw = json["search_type"].string
		{
			if let searchType = HLSearch.ListingType(rawValue: searchTypeRaw)
			{
				search.listingType = searchType
			} else
			{
				log.error("Unknown listing type value from server: \(searchTypeRaw)")
			}
		}
		
		if let isBusta = json["is_busta"].bool
		{
			search.isBlockBusta = isBusta
		}
		
		if let minPrice = json["min_price"].int
		{
			search.minPrice = minPrice
		}
		
		if let maxPrice = json["max_price"].int
		{
			search.maxPrice = maxPrice
		}
		
		if let minBeds = json["beds"].int
		{
			search.minBeds = minBeds
		}
		
		if let minBaths = json["baths"].int
		{
			search.minBaths = minBaths
		}
		
		if let propertyTypeRaw = json["property_type"].string
		{
			if let propertyType = HLProperty.PropertyType(rawValue: propertyTypeRaw)
			{
				search.propertyType = propertyType
			} else
			{
				log.error("Unknown property type value from server: \(propertyTypeRaw)")
			}
		}
		
		if let minSqFt = json["min_sqft"].int
		{
			search.minSqFt = minSqFt
		}
		
		if let minLot = json["min_lot"].int
		{
			search.minLot = minLot
		}
		
		if let minYear = json["min_year"].int
		{
			search.minYear = minYear
		}
		
		if let listingAgeRaw = json["listing_age"].string
		{
			if let listingAge = HLSearch.ListingAge(rawValue: listingAgeRaw)
			{
				search.listingAge = listingAge
			} else
			{
				log.error("Unknown listing age value from server: \(listingAgeRaw)")
			}
		}
		
		if let zips = json["zips"].array?.flatMap({ $0.int })
		{
			search.zips = zips
		} else
		{
			let address = Address()
			var addressExists = false
			
			if let state = json["state"].string
			{
				address.state = state
				addressExists = true
			}
			
			if let county = json["county"].string
			{
				address.county = county
				addressExists = true
			}
			
			if let city = json["city"].string
			{
				address.city = city
				addressExists = true
			}
			
			if let zip = json["zip"].int
			{
				address.zip = zip
				addressExists = true
			}
			
			if addressExists
			{
				search.address = address
			}
		}
		
		if let title = json["title"].string
		{
			search.title = title
		}
		
		if let savedOn = json["saved_on"].string
		{
			log.info("Date string \(savedOn)")
		}
		
		if let results = json["results"].int
		{
			search.results = results
		}
		
		return search
	}
}