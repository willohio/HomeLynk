//
//  ModelCache.swift
//  HomeLynk
//
//  Created by Ivan Dilchovski on 2/26/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation

class ModelCache
{
	static let sharedInstance = ModelCache()
	
	// MARK: - Cached property images
	
	private var cachedPropertyPicturesData = NSCache()
	
	func cacheImagesData(images: [NSData], forPropertyId propertyId: Int)
	{
		cachedPropertyPicturesData[propertyId] = images
	}
	
	func getCachedImagesDataForPropertyid(propertyId: Int) -> [NSData]?
	{
		return cachedPropertyPicturesData[propertyId] as? [NSData]
	}
	
	func cachedCountForPropertyId(propertyId: Int) -> Int
	{
		return cachedPropertyPicturesData[propertyId]?.count ?? 0
	}
	
	// MARK: - Cached search results
	
	// NOTE: Caches properties as returned by the RETS server, filtered with only the DQML query string
	// Key is the DQML query

	private var cachedSearcheResults = [String : [HLProperty]]()
	
	
	func cacheResults(properties: [HLProperty], forSearch search: String)
	{
		cachedSearcheResults[search] = properties
	}
	
	func getSearchResults(search: String) -> [HLProperty]?
	{
		return cachedSearcheResults[search]
	}
}

