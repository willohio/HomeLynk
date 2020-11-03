//
//  NYRetsSearchRequest.swift
//  HomeLynk
//
//  Created by Ivan Dilchovski on 1/29/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation

import Alamofire
import SWXMLHash

class NYRetsSearchRequest: Request
{
	class func search(
		searchType searchType: RetsSearchType,
		dqmlString: String,
		selectString: String,
		startIndex: Int,
		successHandler success:  ((xml: XMLIndexer) -> ())?,
		failureHandler failure: ((requestError: RequestError) -> ())?) -> Alamofire.Request
	{
		let searchEndPoint = NYRetsSearchEndpoint.Search(
			searchType: searchType,
			searchQuery: dqmlString,
			selectFields: selectString,
			limit: Constants.Values.propertyResultsPerRequest,
			index: startIndex)
		
		return makeRequestToEndpoint(searchEndPoint,
			withXMLResponseHandler: { (xml) -> () in
				if let replyCodeString = xml["RETS"].element?.attributes["ReplyCode"], replyCode = Int(replyCodeString) where replyCode == 20701 //Not logged in
				{
					log.info("Not logged in rets. Logging back in.")
					NYRetsLoginRequest.login(
						username: SecureConstants.Accounts.NYRets.password,
						password: SecureConstants.Accounts.NYRets.password,
						successHandler: { () -> () in
							log.info("Logged back in rets")
						}, failureHandler: { (error) -> () in
							log.error("Could not log in to rets after being logged out: \(error)")
					})
					failure?(requestError: RequestError.StatusCode(statusCode: 401, message: "Logged out due to inactivity"))
				} else
				{
					success?(xml: xml)
				}
			},
			failureHandler: { (requestError) -> () in
				
		})
	}
	
}