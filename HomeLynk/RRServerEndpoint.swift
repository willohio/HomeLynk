//
//  ServerEndpoint.swift
//  HomeLynk
//
//  Created by Ivan Dilchovski on 1/23/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation
import Alamofire

enum ServerEndpoint: Endpoint
{
	case List
	
	var baseURL: String {
		return Constants.URLStrings.retsRabbit
	}
	
	var path : String {
		switch self
		{
			case .List: return "/server"
		}
	}
	
	var method: Alamofire.Method {
		switch self
		{
		case .List: return .GET
		}
	}
	
	var parameters: [String : AnyObject]? {
		switch self
		{
			case .List: return nil
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