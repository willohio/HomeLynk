//
//  Endpoint.swift
//  HomeLynk
//
//  Created by Ivan Dilchovski on 1/23/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation
import Alamofire

protocol Endpoint
{
	var baseURL: String { get }
	var path: String { get }
	var method: Alamofire.Method { get }
	var parameters: [String : AnyObject]? { get }
	var encoding: Alamofire.ParameterEncoding { get }
	var headers: [String : String]? { get }
}

extension Endpoint
{	
	var authTokenAndMail: (email: String, token: String)?
	{
		if let (email, token) = LoginHelper.getEmailAndTokenFromKeychain()
		{
			return (email, token)
		} else if let currentUser = HLUser.currentUser, email = currentUser.email, token = HLUser.currentUserAuthToken
		{
			return (email, token)
		} else
		{
			return nil
		}
	}
}
