//
//  ListingEndpoint.swift
//  HomeLynk
//
//  Created by Ivan Dilchovski on 1/23/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation
import Alamofire

enum ListingEndpoint: Endpoint
{
	case Search(serverHash: String, searchParams: [String : AnyObject])
	case GetListing(serverHash: String, listingId: String)
	
	var baseURL: String {
		return Constants.URLStrings.retsRabbit
	}
	
	var path : String {
		switch self
		{
			case .Search(let serverHash, _): return "/\(serverHash)/listing/search"
			case .GetListing(let serverHash, let listingId): return "/\(serverHash)/listing/\(listingId)"
		}
	}
	
	var method: Alamofire.Method {
		switch self
		{
			case .Search: return .GET
			case .GetListing: return .GET
		}
	}
	
	var parameters: [String : AnyObject]? {
		switch self
		{
			case .Search(_, let searchParams): return searchParams
			case .GetListing: return nil
		}
	}
	
	var encoding: Alamofire.ParameterEncoding {
		switch self
		{
			default: return .URLEncodedInURL
		}
	}
	
	var headers: [String : String]? {
		return nil
	}
}
