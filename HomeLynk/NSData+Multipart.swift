//
//  NSData+Multipart.swift
//  HomeLynk
//
//  Created by William Santiago on 1/30/16.
//  Copyright © 2016 William Santiago. All rights reserved.
//

import Foundation

extension NSData
{
	func componentsSeparatedByData(separator : NSData) -> [NSData]
	{
		var components = [NSData]()
		
		// Find first occurrence of separator:
		var searchRange = NSMakeRange(0, self.length)
		var foundRange = self.rangeOfData(separator, options: [], range: searchRange)
		while foundRange.location != NSNotFound
		{
			// Append component (if not empty):
			if foundRange.location > searchRange.location
			{
				components.append(self.subdataWithRange(NSMakeRange(searchRange.location, foundRange.location - searchRange.location)))
			}
			// Search next occurrence of separator:
			searchRange.location = foundRange.location + foundRange.length
			searchRange.length = self.length - searchRange.location
			foundRange = self.rangeOfData(separator, options: [], range: searchRange)
		}
		// Check for final component:
		if searchRange.length > 0
		{
			components.append(self.subdataWithRange(searchRange))
		}
		
		return components
	}
	
	func trimming(dataToTrim: NSData) -> NSData
	{
		let startRange = self.rangeOfData(dataToTrim, options: [NSDataSearchOptions.Anchored] , range: NSMakeRange(0, self.length))
		let endRange = self.rangeOfData(dataToTrim, options: [NSDataSearchOptions.Anchored, NSDataSearchOptions.Backwards] , range: NSMakeRange(0, self.length))
		
		var trimmedDataRange = NSMakeRange(0, self.length)
		
		if startRange.location != NSNotFound
		{
			trimmedDataRange.location = startRange.length
			trimmedDataRange.length -= startRange.length
		}
		
		if endRange.location != NSNotFound
		{
			trimmedDataRange.length = endRange.location
			trimmedDataRange.length -= endRange.length
		}
		
		if trimmedDataRange.location != 0 && trimmedDataRange.length != self.length
		{
			return self.subdataWithRange(trimmedDataRange)
		} else
		{
			return self
		}
	}
	
	func splitMultipartData(boundary boundary: String) -> [[String : AnyObject]]?
	{
		let boundaryBytes = boundary.dataUsingEncoding(NSASCIIStringEncoding)!
		let whitespaceNewLineData = "\r\n".dataUsingEncoding(NSASCIIStringEncoding)!
		
		let data = self.trimming(whitespaceNewLineData).trimming("--".dataUsingEncoding(NSASCIIStringEncoding)!)
		let parts = data.componentsSeparatedByData(boundaryBytes)
		var parsedParts = [[String : AnyObject]]()
		
		for part in parts
		{
			let fieldsSeparator = "\r\n\r\n".dataUsingEncoding(NSASCIIStringEncoding)!
			let headerSeparator = "\r\n".dataUsingEncoding(NSASCIIStringEncoding)!
			
			let trimmedPart = part.trimming(whitespaceNewLineData)
			var partDict = [String : AnyObject]()
			let fields = trimmedPart.componentsSeparatedByData(fieldsSeparator)
			var headers = [String : String]()
			
			for headerData in fields[0].componentsSeparatedByData(headerSeparator)
			{
				guard let headerString = String(data: headerData, encoding: NSASCIIStringEncoding)
					else
				{
					log.error("Error parsing header from data")
					continue
				}
				
				let keyValues = headerString.componentsSeparatedByString(": ")
				if keyValues.count == 2
				{
					let key = keyValues[0].stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())
					let value = keyValues[1].stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())
				
					headers[key] = value
				}
			}
			
			partDict[Constants.Keys.kMultipartDataHeaders] = headers
			partDict[Constants.Keys.kMultipartDataBody] = fields[1]
			
			parsedParts.append(partDict)
		}
		
		return parsedParts
	}
}
