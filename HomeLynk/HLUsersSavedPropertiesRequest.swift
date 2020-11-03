//
//  HLUsersSavedPropertiesRequest.swift
//  HomeLynk
//
//  Created by Ivan Dilchovski on 2/2/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation
import Alamofire

class HLUsersSavedPropertiesRequest: Request
{
	class func saveProperty(
		propertyMlsid: Int,
		successHandler success: (() -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?) -> Alamofire.Request
	{
		let addPropertyEndpoint = HLUsersSavedPropertiesEndpoint.AddSavedProperty(propertyMlsid: propertyMlsid)
		return makeRequestToEndpoint(addPropertyEndpoint,
			withResponseHandler: { (_) -> () in
				success?()
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
	
	class func getSavedPropertiesForUser(
		successHandler success: ((propertyMlsids: [Int]) -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?) -> Alamofire.Request
	{
		let getPropertiesEndpoint = HLUsersSavedPropertiesEndpoint.GetSavedProperties
		return makeRequestToEndpoint(getPropertiesEndpoint,
			withJSONResponseHandler: { (json) -> () in
				if let savedPropertyIds = json["saved_properties"].array
				{
					var propertyIds = [Int]()
					for propertyIdJson in savedPropertyIds
					{
						if let id = propertyIdJson["property_mlsid"].int
						{
							propertyIds.append(id)
						} else
						{
							log.error("Saved property Mlsid JSON object could not be parsed")
							log.error(propertyIdJson.debugDescription)
						}
					}
					
					success?(propertyMlsids: propertyIds)
				}  else
				{
					log.error("Could not parse saved property ids array from json. Error: \(json["saved_properties"].error)")
					failure?(error: RequestError.BadResponseFormat(json.description))
				}
			},
			failureHandler: { (requestError) -> () in
				log.error("\(requestError)")
				failure?(error: requestError)
		})
	}
	
	class func deleteSavedProperty(
		propertyMlsid: Int,
		successHandler success: (() -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?) -> Alamofire.Request
	{
		let deleteSavedPropertyEndpoint = HLUsersSavedPropertiesEndpoint.DeleteSavedProperty(propertyMlsid: propertyMlsid)
		return makeRequestToEndpoint(deleteSavedPropertyEndpoint,
			withResponseHandler: { (_) -> () in
				success?()
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
}