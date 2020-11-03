//
//  HLPasswordResetRequest.swift
//  HomeLynk
//
//  Created by Ivan Dilchovski on 1/25/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation

import Alamofire
import SwiftyJSON

class HLPasswordResetRequest: Request
{
	class func requestResetForEmail(
		email: String,
		successHandler success: (() -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?) -> Alamofire.Request
	{
		let passwordResetEndpoint = HLPasswordResetEndpoint.RequestReset(email)
		return makeRequestToEndpoint(passwordResetEndpoint,
			withJSONResponseHandler: { (json) -> () in
				success?()
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
}