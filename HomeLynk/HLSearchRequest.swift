//
//  HLSearchRequest.swift
//  HomeLynk
//
//  Created by William Santiago on 2/2/16.
//  Copyright © 2016 William Santiago. All rights reserved.
//

import Foundation
import Alamofire

class HLSearchRequest: Request
{
	class func saveSearch(
		search: HLSearch,
		successHandler success: (() -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?) -> Alamofire.Request
	{
		let saveSearchEndpoint = HLSearchEndpoint.SaveSearch(search: search)
		return makeRequestToEndpoint(saveSearchEndpoint, withJSONResponseHandler: { (json) -> () in
			log.info("Success")
			success?()
			}, failureHandler: { (requestError) -> () in
				log.info("\(requestError)"
				)
				failure?(error: requestError)
		})
	}
	
	class func getSavedSearchesForUser(
		successHandler success: ((searches: [HLSearch]) -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?) -> Alamofire.Request
	{
		let getSavedEndpoint = HLSearchEndpoint.GetSavedSearches
		return makeRequestToEndpoint(getSavedEndpoint,
			withJSONResponseHandler: { (json) -> () in
				if let searchesArray = json["searches"].array
				{
					var searches = [HLSearch]()
					for searchJSON in searchesArray
					{
						if let search = HLSearch.getSearchFromJSON(searchJSON)
						{
							searches.append(search)
						} else
						{
							log.error("HLSearch JSON object could not be parsed")
							log.error(searchJSON.debugDescription)
						}
					}
					
					success?(searches: searches)
				} else
				{
					log.error("Could not parse searches array from json. Error: \(json["searches"].error)")
					failure?(error: RequestError.BadResponseFormat(json.description))
				}
			},
			failureHandler: { (requestError) -> () in
				log.error("\(requestError)")
				failure?(error: requestError)
		})
	}
	
	class func updateSavedSearch(
		search: HLSearch,
		successHandler success: (() -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?) -> Alamofire.Request
	{
		let updateEndpoint = HLSearchEndpoint.Update(search: search)
		return makeRequestToEndpoint(updateEndpoint,
			withResponseHandler: { (_) -> () in
				success?()
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
	
	class func deleteSavedSearch(
		search: HLSearch,
		successHandler success: (() -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?) -> Alamofire.Request
	{
		let deleteSearchEndpoint = HLSearchEndpoint.DeleteSearch(search: search)
		return makeRequestToEndpoint(deleteSearchEndpoint,
			withResponseHandler: { (_) -> () in
				success?()
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
}
