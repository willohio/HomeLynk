//
//  HLZipCodeRequest.swift
//  HomeLynk
//
//  Created by Ivan Dilchovski on 2/25/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation

import Alamofire
import SwiftyJSON

class HLZipCodeRequest: Request
{
	class func findZipsInGeoRect(
		upperLeft upperLeft: CGPoint,
		lowerRight: CGPoint,
		successHandler success: ((zipCodes: [Int]?) -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?) -> Alamofire.Request
	{
		let findZipsEndpoint = HLZipCodeEndpoint.FindZipInGeoRect(upperLeft: upperLeft, lowerRight: lowerRight)
		return makeRequestToEndpoint(findZipsEndpoint,
			withJSONResponseHandler: { (json) -> () in
				if let zipsArray = json["zip_codes"].array
				{
					var zipCodes = [Int]()
					for zipJSON in zipsArray
					{
						if let zip = zipJSON["zip"].int
						{
							zipCodes.append(zip)
						}
					}
					
					success?(zipCodes: (zipCodes.count > 0) ? zipCodes : nil)
				}
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
}