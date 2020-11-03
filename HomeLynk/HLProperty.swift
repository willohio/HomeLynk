//
//  HLProperty.swift
//  HomeLynk
//
//  Created by Ivan Dilchovski on 1/13/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import UIKit
import CoreLocation

class HLProperty
{
	enum PropertyType: String
	{
		case AllTypes			= "All Types"
		case SingleFamily		= "Single Family"
		case MultiFamily		= "Multi Family"
		case CondoTownhouse		= "Condo/Townhouse"
		case Land				= "Land"
		
		static let allValues = [AllTypes, SingleFamily, MultiFamily, CondoTownhouse, Land]
	}
	
	var id: Int?
	var agentId: Int?
	var propertyType: PropertyType?
	var propertyImages: [UIImage]?
	var price: Int?
	var address: String?
	var beds: Int?
	var baths: Int?
	var size: Double?
	var lotSize: Double?
	var yearBuilt: Int?
	
	var forSale: Bool?
	var forRent: Bool?
	var location: CLLocationCoordinate2D?
	
	var listDate: NSDate?
	
	init()
	{
		
	}
	
	init(propertyImages: [UIImage], price: Int, address: String, beds: Int, baths: Int, size: Double)
	{
		self.propertyImages = propertyImages
		self.price = price
		self.address = address
		self.beds = beds
		self.baths = baths
		self.size = size
	}
}