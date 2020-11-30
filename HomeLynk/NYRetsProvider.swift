//
//  NYRetsProvider.swift
//  HomeLynk
//
//  Created by William Santiago on 1/29/16.
//  Copyright © 2016 William Santiago. All rights reserved.
//

import Foundation
import SWXMLHash
import CoreLocation

import Alamofire

class NYRetsProvider: RetsProvider
{
	private static let propertyTypeValues = [
		HLProperty.PropertyType.SingleFamily : [500, 520, 540, 550, 560, 580],
		HLProperty.PropertyType.MultiFamily : [200, 201, 220],
		HLProperty.PropertyType.CondoTownhouse : [530, 535, 560, 590],
		HLProperty.PropertyType.Land : [600],
		
		HLProperty.PropertyType.AllTypes : [200, 201, 220, 500, 520, 540, 550, 580, 530, 560, 600]
	]
	
	private static let selectString = "County,Mlsid,AgentId,PropertyType,Price,SaleRent,Address,Township,State,Zip,Latitude,Longitude,Beds,FullBaths,HalfBaths,LotSize,LotSqft,YearBuilt,AboveArea"
	
	class func getPropertiesFromHLSearch(search: HLSearch,
		successHandler success:  ((properties: [HLProperty]) -> ())?,
		failureHandler failure: ((requestError: RequestError) -> ())?) -> Alamofire.Request?
	{
		let dqmlString = buildDQMLQueryFromSearch(search)
		
		if let cachedResult = ModelCache.sharedInstance.getSearchResults(dqmlString)
		{
			success?(properties: cachedResult)
			
			return nil
		}
		
		// Request if not in cache
		return NYRetsSearchRequest.search(
			searchType: .Property,
			dqmlString: dqmlString,
			selectString: selectString,
			startIndex: 0,
			successHandler: { (xml) -> () in
				if let countString = xml["RETS"]["COUNT"].element?.attributes["Records"], count = Int(countString) where count == 0
				{
					success?(properties: [HLProperty]())
				} else if let properties = getHLPropertiesFromXML(xml)
				{
					let properties = properties.filter { $0.id != nil } // Unlikely, but just in case...
					let filteredProperties = search.filterProperties(properties) // NY RETS filters only on a small subset of the available data fields, so search results must be further filtered
					
					ModelCache.sharedInstance.cacheResults(properties, forSearch: dqmlString)
					
					success?(properties: filteredProperties)
				} else
				{
					if let text = xml.element?.text where text != ""
					{
						failure?(requestError: RequestError.BadResponseFormat(text))
					} else
					{
						failure?(requestError: RequestError.BadResponseFormat("Empty XML"))
					}
				}
			},
			failureHandler: { (requestError) -> () in
				failure?(requestError: requestError)
		})
	}
	
	class func mapHLPropertyTypesToRetsPropertyTypeCodes(hlTypes: [HLProperty.PropertyType]) -> [[Int]]
	{
		let retsTypes = [[Int]]()
		
		return retsTypes
	}
	
	class func buildDQMLQueryFromSearch(search: HLSearch) -> String
	{
		var query = ""
		
		if search.minPrice != nil || search.maxPrice != nil
		{
			query += "(Price="
			
			switch (search.minPrice, search.maxPrice)
			{
				case (let minPrice?, let maxPrice?):
					query += "\(minPrice)-\(maxPrice)"
				
				case (let minPrice?, nil):
					query += "\(minPrice)+"
				
				case (nil, let maxPrice):
					query += "\(maxPrice)-"
				
				default: ()
			}
			
			query += "),"
		} else // nysrets.com requires a price parameter
		{
			query += "(Price=1+),"
		}
		
		if let propertyIds = search.propertyIds where propertyIds.count > 0
		{
			query += "("
			for propertyId in propertyIds
			{
				query += "(Mlsid=\(propertyId))|"
			}
			query = query.substringToIndex(query.endIndex.predecessor())
			query += "),"
		}
		
		if let listingAge = search.listingAge where listingAge != .ShowAll
		{
			query += "(Listdate="
			
			let formatter = NSDateFormatter()
			formatter.dateFormat = "yyyy-MM-dd"
			
			switch listingAge
			{
				case .Days12:
					let date = NSDate().dateByAddingTimeInterval(-(2 * Constants.Values.daysToNSTimeInterval))
					let dateString = formatter.stringFromDate(date)
					log.info(dateString)
					query += dateString + "+"
				case .Days3:
					let date = NSDate().dateByAddingTimeInterval(-(3 * Constants.Values.daysToNSTimeInterval))
					let dateString = formatter.stringFromDate(date)
					query += dateString + "+"
				case .Week1:
					let date = NSDate().dateByAddingTimeInterval(-(7 * Constants.Values.daysToNSTimeInterval))
					let dateString = formatter.stringFromDate(date)
					query += dateString + "+"
				
				case .Month1:
					let date = NSDate().dateByAddingTimeInterval(-(30 * Constants.Values.daysToNSTimeInterval))
					let dateString = formatter.stringFromDate(date)
					query += dateString + "+"
				
				case .ShowAll: log.error("Impossible!")
			}
			
			query += "),"
		}
		
		if let zips = search.zips where zips.count > 0
		{
			query += "(Zip="
			for zip in zips
			{
				query += "\(zip),"
			}
			
			if query.characters.last == ","
			{
				query = query.substringToIndex(query.endIndex.predecessor()) //Truncate last ,
			}
			query += "),"
			
		} else
		{
			if let state = search.address?.state
			{
				query += "(State=\(state)),"
			}
			
			if let zip = search.address?.zip
			{
				query += "(Zip=\(zip)),"
			} else if let city = search.address?.city
			{
				query += "(Township=\"\(city)\"),"
			}
			
			// Leaves out lots of properties
			
	//		if let county = search.county
	//		{
	//			query += "(County=\"\(county)\"),"
	//		}

		}
		
		if let propertyType = search.propertyType, typeValues = propertyTypeValues[propertyType]
			where typeValues.count > 0
		{
			query += "(PropertyType=|"
			
			for value in typeValues
			{
				query += "\(value),"
			}
			
			query = query.substringToIndex(query.endIndex.predecessor()) //Truncate last ,
			query += ")"
		}
		
		if query.characters.last == ","
		{
			query = query.substringToIndex(query.endIndex.predecessor()) //Truncate last ,
		}
		
		print(query)
		
		return query
	}
	
	class func getHLPropertiesFromXML(xml: XMLIndexer) -> [HLProperty]?
	{
		guard let columnsString = xml["RETS"]["COLUMNS"].element?.text
			else
		{
			log.error("Missing columns in xml")
			return nil
		}
		
		let columnComponents = columnsString.componentsSeparatedByString("\t")
		
		var properties = [HLProperty]()
		
		for propertyXML in xml["RETS"]["DATA"]
		{
			guard let propertyString = propertyXML.element?.text
				else
			{
				log.error("DATA element with no text")
				continue
			}
			
			var propertyDictionary = [String : String]()
			let propertyComponents = propertyString.componentsSeparatedByString("\t")
			
			guard propertyComponents.count == columnComponents.count
				else
			{
				log.error("Number of columns differs from number of property attributes")
				continue
			}
			
			for (index, columnName) in columnComponents.enumerate()
			{
				let propertyField = propertyComponents[index]
				propertyDictionary[columnName] = propertyField
			}
			
			guard let idString = propertyDictionary["Mlsid"], id = Int(idString) where id > 0
				else
			{
				log.error("No ID for property")
				continue
			}
			
			guard let agentIdString = propertyDictionary["AgentId"], agentId = Int(agentIdString) where id > 0
				else
			{
				log.error("No agent for property \(id)")
				continue
			}
			
			let property = HLProperty()
			property.id = id
			property.agentId = agentId
			
			if let propertyTypeValueString = propertyDictionary["PropertyType"], propertyTypeValue = Int(propertyTypeValueString)
				where propertyTypeValue > 0
			{
				for (propertyType, typeValues) in propertyTypeValues
				{
					guard propertyType != .AllTypes
						else
					{
						continue
					}
					
					if typeValues.contains(propertyTypeValue)
					{
						property.propertyType = propertyType
					}
				}
			}
			
			if let priceString = propertyDictionary["Price"], price = Int(priceString)
				where price > 0
			{
				property.price = price
			}
			
			if let saleRent = propertyDictionary["SaleRent"]
			{
				if saleRent == "S"
				{
					property.forSale = true
					property.forRent = false
				} else if saleRent == "R"
				{
					property.forRent = true
					property.forSale = false
				} else
				{
					property.forRent = true
					property.forSale = true
				}
			}
			
			if let address = propertyDictionary["Address"]
			{
				if property.address == nil
				{
					property.address = ""
				}
				
				property.address! += address
			}
			
			if let township = propertyDictionary["Township"]
			{
				if property.address == nil
				{
					property.address = ""
				} else
				{
					property.address! += ", "
				}
				
				property.address! += township
			}
			
			if let state = propertyDictionary["State"]
			{
				if property.address == nil
				{
					property.address = ""
				} else
				{
					property.address! += ", "
				}
				
				property.address! += state
			}
			
			if let zip = propertyDictionary["Zip"]
			{
				if property.address == nil
				{
					property.address = ""
				} else
				{
					property.address! += ", "
				}
				
				property.address! += zip
			}

			if let latitudeString = propertyDictionary["Latitude"],
				longitudeString = propertyDictionary["Longitude"],
				latitude = Double(latitudeString),
				longitude = Double(longitudeString)
				where latitude != 0 && longitude != 0
			{
				property.location = CLLocationCoordinate2DMake(latitude, longitude)
			}
			
			if let bedsString = propertyDictionary["Beds"], beds = Int(bedsString) //Bads may actually be 0, so no WHERE
			{
				property.beds = beds
			}
			
			if let bathsString = propertyDictionary["FullBaths"], baths = Int(bathsString)
			{
				property.baths = baths
			}
			
			if let bathsString = propertyDictionary["HalfBaths"], baths = Int(bathsString)
			{
				if property.baths != nil
				{
					property.baths! += baths
				} else
				{
					property.baths = baths
				}
			}
			
			if let lotSizeString = propertyDictionary["LotSize"], lotSize = Double(lotSizeString) where lotSize > 0
			{
				property.lotSize = lotSize * 43560 //Acre to sq ft
			} else if let lotSqftString = propertyDictionary["LotSqft"], lotSqft = Double(lotSqftString) where lotSqft > 0
			{
				property.lotSize = lotSqft
			}
			
			if let sizeString = propertyDictionary["AboveArea"], size = Double(sizeString) where size > 0
			{
				property.size = size
			}
			
			if let yearBuiltString = propertyDictionary["YearBuilt"], yearBuilt = Int(yearBuiltString) where yearBuilt > 0
			{
				property.yearBuilt = yearBuilt
			}
			
			properties.append(property)
		}
		
		return properties
	}
}
