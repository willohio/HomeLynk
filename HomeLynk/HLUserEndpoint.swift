//
//  HLUserEndpoint.swift
//  HomeLynk
//
//  Created by Ivan Dilchovski on 1/23/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation

import Alamofire

enum HLUserEndpoint: Endpoint
{
	case GetUser(id: Int)
	case CreateUser(user: HLUser, password: String, passwordConfirm: String)
	case UpdateUser(HLUser, String?, String?)
	case DeleteUser(HLUser)
	
	var baseURL: String {
		return Constants.URLStrings.homeLynkServer
	}
	
	var path : String {
		switch self
		{
			case .GetUser(let id):			return "/users/\(id)"
			case .CreateUser(_):			return "/users"
			case .UpdateUser(let user, _, _):		return "/users/\(user.id)"
			case .DeleteUser(let user):		return "/users/\(user.id)"
		}
	}
	
	var method: Alamofire.Method {
		switch self
		{
			case .GetUser(_):		return .GET
			case .CreateUser(_):	return .POST
			case .UpdateUser(_):	return .PUT
			case .DeleteUser(_):	return .DELETE
		}
	}
	
	var parameters: [String : AnyObject]? {
		switch self
		{
			case .GetUser(_):													return nil
				
			case .CreateUser(let user, let password, let passwordConfirm):
				var params =  ["user" :	["email"				: user.email ?? "",
										"password"				: password,
										"password_confirmation" : passwordConfirm,
										"firstname"				: user.firstName ?? "",
										"lastname"				: user.lastName ?? ""]]
				if let phone = user.phone
				{
					params["user"]!["phone"] = phone
				}
				
				if let age = user.age
				{
					params["user"]!["age"] = age
				}
				
				return params
			
				
			case .UpdateUser(let user, let password, let passwordConfirm):
				var params = [String : Dictionary<String, String>]()
				
				if let password = password, passwordConfirm = passwordConfirm
				{
					params =  ["user" :	["email"				: user.email ?? "",
										"password"				: password,
										"password_confirmation" : passwordConfirm,
										"firstname"				: user.firstName ?? "",
										"lastname"				: user.lastName ?? ""]]
				} else
				{
					params = ["user" :	["email"				: user.email ?? "",
										"firstname"				: user.firstName ?? "",
										"lastname"				: user.lastName ?? ""]]
				}
			
				if let phone = user.phone
				{
					params["user"]!["phone"] = phone
				}
				
				if let age = user.age
				{
					params["user"]!["age"] = age
				}
			
			return params
			
			case .DeleteUser(_):
				return nil
		}
	}
	
	var encoding: Alamofire.ParameterEncoding {
		switch self
		{
			default: return .JSON
		}
	}
	
	var headers: [String : String]? {
		var headers = [String : String]()
		
		switch self
		{
			default:
				headers["Accept"] = "application/json"
		}
		
		switch self
		{
			case .DeleteUser(_), .UpdateUser(_):
				if let (email, token) = authTokenAndMail
				{
					let authHeader = "Token token=\"\(token)\", email=\"\(email)\""
					headers["Authorization"] = authHeader
				}
			default: ()
		}
		
		return headers
	}
	
}