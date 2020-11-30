//
//  RETSProvider.swift
//  HomeLynk
//
//  Created by William Santiago on 1/29/16.
//  Copyright © 2016 William Santiago. All rights reserved.
//

import Foundation

import Alamofire

enum RetsSearchType
{
	case Property
	case Agent
}

protocol RetsProvider
{
	static func getPropertiesFromHLSearch(search: HLSearch,
		successHandler success:  ((properties: [HLProperty]) -> ())?,
		failureHandler failure: ((requestError: RequestError) -> ())?) -> Alamofire.Request?
}
