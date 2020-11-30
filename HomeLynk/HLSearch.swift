//
//  HLSearch.swift
//  HomeLynk
//
//  Created by William Santiago on 1/21/16.
//  Copyright © 2016 William Santiago. All rights reserved.
//

import Foundation

class HLSearch
{
	enum ListingAge: String
	{
		case ShowAll			= "Show All"
		case Days12				= "1-2 Days"
		case Days3				= "3 Days"
		case Week1				= "1 Week"
		case Month1				= "1 Month"
		
		static let allValues = [ShowAll, Days12, Days3, Week1, Month1]
	}
	
	enum ListingType: String
	{
		case Sale = "Sale"
		case Rent = "Rent"
		case Any  = "Any"
		
		static let allValues = [Any, Sale, Rent]
	}
	
	class Address
	{
		var state: String?
		var county: String?
		var zip: Int?
		var city: String?
		var street: String?
	}
	
	// MARK: - Properties
	
	var isBlockBusta = false
	
	var id: Int?	// Backend ID, if a saved search
	var listingType: ListingType? = nil
	var propertyIds: [Int]? = nil //Search only within specific property IDs
	var minPrice: Int? = nil
	var maxPrice: Int? = nil
	var minBeds: Int? = nil
	var minBaths: Int? = nil
	var propertyType: HLProperty.PropertyType? = nil
	var minSqFt: Int? = nil
	var minLot: Int? = nil
	var minYear: Int? = nil
	var listingAge: ListingAge? = nil
	
	var address: Address? = nil
	var zips: [Int]? = nil
	
	var title: String? = nil
	var savedOn: NSDate? = nil
	var results: Int? = nil
	
	// MARK: - Func
	
	func filterProperties(properties: [HLProperty]) -> [HLProperty]
	{
		var filteredProperties = properties
		
		filteredProperties = filteredProperties.filter { !Settings.User.hiddenProperties.contains($0.id!) }
		
		if let listingType = listingType
		{
			filteredProperties = filteredProperties.filter { (property) -> Bool in
				switch (listingType, property.forRent, property.forSale)
				{
					case (.Sale, _, .Some(let forSale)):
						return forSale
					
					case (.Rent, .Some(let forRent), _):
						return forRent
					
					case (.Any, _, _):
						return true
					
					default:
						return false
				}
			}
		}
		
		if let minBeds = self.minBeds
		{
			filteredProperties = filteredProperties.filter { (property) -> Bool in
				guard let propertyBeds = property.beds
					else
				{
					return false
				}
				
				return propertyBeds >= minBeds
			}
		}
		
		if let minBaths = self.minBaths
		{
			filteredProperties = filteredProperties.filter({ (property) -> Bool in
				guard let propertyBeds = property.baths
					else
				{
					return false
				}
				
				return propertyBeds >= minBaths
			})
		}
		
		if let minLot = self.minLot
		{
			filteredProperties = filteredProperties.filter({ (property) -> Bool in
				guard let propertyLot = property.lotSize
					else
				{
					return false
				}
				
				return Int(propertyLot) >= minLot
			})
		}
		
		if let minSize = self.minSqFt
		{
			filteredProperties = filteredProperties.filter({ (property) -> Bool in
				guard let propertySize = property.size
					else
				{
					return false
				}
				
				return Int(propertySize) >= minSize
			})
		}
		
		if let minYear = self.minYear
		{
			filteredProperties = filteredProperties.filter({ (property) -> Bool in
				guard let propertyYear = property.yearBuilt
					else
				{
					return false
				}
				
				return propertyYear >= minYear
			})
		}
		
		return filteredProperties
	}

	
}
