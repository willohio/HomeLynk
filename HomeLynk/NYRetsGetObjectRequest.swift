//
//  NYRetsGetObjectRequest.swift
//  HomeLynk
//
//  Created by William Santiago on 1/30/16.
//  Copyright © 2016 William Santiago. All rights reserved.
//

import Foundation
import Alamofire


class NYRetsGetObjectRequest: Request
{
	class func getPhotosForPropertyIds(
		ids: [Int],
		firstPhotoOnly: Bool,
		successHandler success:  ((photos: [Int : [NSData]]) -> ())?,
		failureHandler failure: ((requestError: RequestError) -> ())?) -> Alamofire.Request?
	{
		log.info("Get photos for \(ids). First only: \(firstPhotoOnly)")
		
		var cachedPropertyImagesData = [Int : [NSData]]()
		let notCachedPropertyIds: [Int] = ids.filter({ (id) -> Bool in
			if let cachedImages = ModelCache.sharedInstance.getCachedImagesDataForPropertyid(id)
			{
				if firstPhotoOnly && cachedImages.count > 1 // If only first requested and there are more than 1 in cache - get only the first
				{
					cachedPropertyImagesData[id] = [cachedImages.first!]
					return false
				} else if !firstPhotoOnly && cachedImages.count == 1 // If all are requested, but there is only one in cache - Maybe it's from a previous request when only 1st was requested? Request all again
				{
					return true
				} else
				{
					cachedPropertyImagesData[id] = cachedImages
					return false
				}
			} else
			{
				return true
			}
		})
		
		log.info("Cached: \(cachedPropertyImagesData.count). Not cached: \(notCachedPropertyIds.count)")
		
		if notCachedPropertyIds.count == 0
		{
			log.info("All from cache")
			success?(photos: cachedPropertyImagesData)
			return nil
		}
		
		// If there are properties with no photos fetch, fetch them
		
		let photosEndpoint = NYRetsGetObjectEndpoint.GetPictures(propertyIds: ids, firstOnly: firstPhotoOnly)
		return makeRequestToEndpoint(photosEndpoint,
			withDataResponseHandler: { (data, multipartBoundary) -> () in
				if let multipartBoundary = multipartBoundary // Data has multipart boundary - it is multiple images transmitted together in a single response
				{
					log.info("Received photos for \(ids)")
					
					if let dataDictionaries = data.splitMultipartData(boundary: multipartBoundary)
					{
						var photos = [Int : [NSData]]()
						var tempPhotosDict = [Int: [Int : NSData]]() // Store photos key'd by the Object-Id header (photo num from server	), key'd by property ID
						for dict in dataDictionaries
						{							
							if let headers = dict[Constants.Keys.kMultipartDataHeaders] as? [String : String]
							{
								if let contentType = headers[Constants.Keys.kHTTPHeaderContentType],
									propertyIdString =  headers[Constants.Keys.kHTTPHeaderContentID],
									objectIdString = headers[Constants.Keys.kHTTPHeaderObjectID],
									propertyId = Int(propertyIdString),
									objectId = Int(objectIdString)
									where contentType == Constants.Keys.kMIMETypeImage
								{
									if tempPhotosDict[propertyId] == nil
									{
										tempPhotosDict[propertyId] = [Int : NSData]()
									}
									
									if let data = dict[Constants.Keys.kMultipartDataBody] as? NSData
									{
										tempPhotosDict[propertyId]![objectId] = data
									} else
									{
										log.error("Error getting photo data from data dictionary")
										continue
									}
									
								} else
								{
									log.error("Bad HTTP headers for image:\n\(headers)")
									continue
								}
							} else
							{
								log.error("No headers in data dictionary")
								continue
							}
						}
						
						//Sort the photos as per the object-id from server
						for (propertyId, propertyPicsIndexedData) in tempPhotosDict
						{
							if photos[propertyId] == nil
							{
								photos[propertyId] = [NSData]()
							}
							
							//The keys are the object-ids given by the server
							//Sort by id and append
							for photoIndex in Array(propertyPicsIndexedData.keys.sort {$0 < $1} )
							{
								photos[propertyId]!.append(propertyPicsIndexedData[photoIndex]!)
							}
							
							if !firstPhotoOnly // Don't overwrite many images with a single one
							{
								ModelCache.sharedInstance.cacheImagesData(photos[propertyId]!, forPropertyId: propertyId)
							} else
							{
								if ModelCache.sharedInstance.cachedCountForPropertyId(propertyId) <= 1
								{
									ModelCache.sharedInstance.cacheImagesData(photos[propertyId]!, forPropertyId: propertyId)
								}
							}
							
						}
						
						for (propertyId, imagesData) in cachedPropertyImagesData
						{
							if photos[propertyId] == nil // Do not overwrite fresh data
							{
								photos[propertyId] = imagesData
							}
						}
						
						log.info("Parsed \(photos.count)")
						success?(photos: photos)
					} else
					{
						failure?(requestError: RequestError.BadResponseFormat("Error parsing multipart data"))
					}
				} else //If not multipart - then it's a single image
				{
					success?(photos: [ids[0] : [data]])
				}
			},
			failureHandler: { (requestError) -> () in
				failure?(requestError: requestError)
		})
	}
}
