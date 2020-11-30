//
//  Request.swift
//  HomeLynk
//
//  Created by William Santiago on 1/23/16.
//  Copyright © 2016 William Santiago. All rights reserved.
//

import Foundation

import Alamofire
import SwiftyJSON
import SWXMLHash

protocol Request
{
	static func makeRequestToEndpoint(endpoint: Endpoint,
		withJSONResponseHandler jsonResponseHandler:  ((json: JSON) -> ())?,
		failureHandler failure: ((requestError: RequestError) -> ())?) -> Alamofire.Request
	
	static func makeRequestToEndpoint(endpoint: Endpoint,
		withXMLResponseHandler xmlResponseHandler:  ((xml: XMLIndexer) -> ())?,
		failureHandler failure: ((requestError: RequestError) -> ())?) -> Alamofire.Request
	
	static func makeRequestToEndpoint(endpoint: Endpoint,
		withDataResponseHandler dataResponseHandler:  ((data: NSData, multipartBoundary: String?) -> ())?,
		failureHandler failure: ((requestError: RequestError) -> ())?) -> Alamofire.Request
	
	static func makeAuthenticatedRequestToEndpoint(
		endpoint: Endpoint,
		username: String,
		password: String,
		successHandler success: () -> (),
		failureHandler failure: ((requestError: RequestError) -> ())?) -> Alamofire.Request
}

extension Request
{
	static func makeRequestToEndpoint(endpoint: Endpoint,
		withResponseHandler responseHandler:  ((NSHTTPURLResponse) -> ())?,
		failureHandler failure: ((requestError: RequestError) -> ())?) -> Alamofire.Request
	{
		return Alamofire.request(endpoint.method, endpoint.baseURL + endpoint.path, parameters: endpoint.parameters, encoding: endpoint.encoding, headers: endpoint.headers).responseString(completionHandler: { (response) -> Void in
			//			print(" ")
			//			log.info(String(reflecting: response))
			//			print(" ")
		}).response { (request, response, data, error) -> Void in
			if let error = error
			{
				if error.domain == NSURLErrorDomain && error.code == -1004
				{
					log.error("No network connection")
					failure?(requestError: .NoConnection)
				} else
				{
					if error.localizedDescription == "cancelled" // TODO: description may change? Use better check for cancellation
					{
						log.error("Cancelled")
						failure?(requestError: .Cancelled)
					} else
					{
						log.error("Error with request to server: \(error.localizedDescription)")
						failure?(requestError: .Other(error.localizedDescription))
					}
				}
			} else if let response = response
			{
				print(" ")
				log.verbose(String(reflecting: response))
				print(" ")
				
				if response.statusCode >= 200 && response.statusCode <= 299
				{
					log.info("Request success")
					responseHandler?(response)
				} else
				{
					log.error("Bad status code \(response.statusCode)")
					failure?(requestError: RequestError.StatusCode(statusCode: response.statusCode, message: "Status code != 2xx"))
				}
			} else
			{
				log.error("No response from server")
				failure?(requestError: .Other("No response from server"))
			}
		}
	}
	
	static func makeRequestToEndpoint(endpoint: Endpoint,
		withJSONResponseHandler jsonResponseHandler:  ((json: JSON) -> ())?,
		failureHandler failure: ((requestError: RequestError) -> ())?) -> Alamofire.Request
	{
		return Alamofire.request(
			endpoint.method,
			endpoint.baseURL + endpoint.path,
			parameters: endpoint.parameters,
			encoding: endpoint.encoding,
			headers: endpoint.headers
		).responseString { (response) -> Void in
				print(" ")
				log.verbose(String(reflecting: response))
				print(" ")
		}.responseJSON { (response) -> Void in
			if let error = response.result.error
			{
				if error.domain == NSURLErrorDomain && error.code == -1004
				{
					log.error("No network connection")
					failure?(requestError: .NoConnection)
				} else
				{
					if error.localizedDescription == "cancelled" // TODO: description may change? Use better check for cancellation
					{
						log.error("Cancelled")
						failure?(requestError: .Cancelled)
					} else
					{
						log.error("Error with request to server: \(error.localizedDescription)")
						failure?(requestError: .Other(error.localizedDescription))
					}
				}
			} else
			{
				if let value: AnyObject = response.result.value, statusCode = response.response?.statusCode
				{
					let json = JSON(value)
					
					guard json.error == nil
						else
					{
						log.error("Unprocessable JSON response: \(json.error!.description)")
						failure?(requestError: .BadResponseFormat("Unprocessable JSON response: \(json.error!.description)"))
						
						return
					}
					
					if let status = json["status"].string where status == "success"
					{
						if statusCode >= 200 && statusCode <= 299 //Only possible way for success
						{
							log.info("Request success")
							jsonResponseHandler?(json: json["data"])
						} else
						{
							log.error("Success status in JSON, but status code != 2xx !") // JSON object claims success, but the status code is wrong?
							jsonResponseHandler?(json: json["data"])
						}
					} else if let status = json["status"].string where status == "error"
					{
						var errorString = ""
						for (_, error): (String, JSON) in json["errors"]
						{
							errorString += "\(error["title"].stringValue)\n"
						}
						
						log.error("JSON error status. Status Code \(statusCode). JSON Error Message \(errorString)")
						failure?(requestError: .StatusCode(statusCode: statusCode, message: errorString))
					} else if json["status"].string == nil
					{
						log.error("No status in JSON")
						failure?(requestError: .BadResponseFormat("No status in JSON"))
					}
				} else
				{
					if let statusCode = response.response?.statusCode
					{
						log.error("Status code \(statusCode) with nil response")
						failure?(requestError: .StatusCode(statusCode: statusCode, message: "Nil response"))
					} else
					{
						log.error("No response value and no status code")
						failure?(requestError: .BadResponseFormat("No response value and no status code"))
					}
				}
			}
		}
	}
	
	static func makeRequestToEndpoint(endpoint: Endpoint,
		withXMLResponseHandler xmlResponseHandler:  ((xml: XMLIndexer) -> ())?,
		failureHandler failure: ((requestError: RequestError) -> ())?) -> Alamofire.Request
	{
		return Alamofire.request(
			endpoint.method,
			endpoint.baseURL + endpoint.path,
			parameters: endpoint.parameters,
			encoding: endpoint.encoding,
			headers: endpoint.headers
		).responseString { (response) -> Void in
			print(" ")
			log.verbose(String(reflecting: response))
			print(" ")
			
			if let error = response.result.error
			{
				if error.domain == NSURLErrorDomain && error.code == -1004
				{
					log.error("No network connection")
					failure?(requestError: .NoConnection)
				} else
				{
					if error.localizedDescription == "cancelled" // TODO: description may change? Use better check for cancellation
					{
						log.error("Cancelled")
						failure?(requestError: .Cancelled)
					} else
					{
						log.error("Error with request to server: \(error.localizedDescription)")
						failure?(requestError: .Other(error.localizedDescription))
					}
				}
			} else
			{
				if let value = response.result.value, statusCode = response.response?.statusCode where statusCode >= 200 && statusCode <= 299
				{
					let xml = SWXMLHash.parse(value)
					xmlResponseHandler?(xml: xml)
				} else
				{
					if let statusCode = response.response?.statusCode
					{
						failure?(requestError: .StatusCode(statusCode: statusCode, message: "Status code != 2xx"))
					} else
					{
						failure?(requestError: .Other("Other error parsing response for JSON"))
					}
				}
			}
		}
	}
	
	static func makeRequestToEndpoint(endpoint: Endpoint,
		withDataResponseHandler dataResponseHandler:  ((data: NSData, multipartBoundary: String?) -> ())?,
		failureHandler failure: ((requestError: RequestError) -> ())?) -> Alamofire.Request
	{
		return Alamofire.request(
			endpoint.method,
			endpoint.baseURL + endpoint.path,
			parameters: endpoint.parameters,
			encoding: endpoint.encoding,
			headers: endpoint.headers).authenticate(
				user: SecureConstants.Accounts.NYRets.username,
				password: SecureConstants.Accounts.NYRets.password
		).responseData { (response) -> Void in
			print("")
			log.verbose(String(reflecting: response.request))
			log.verbose(String(reflecting: response.response))
			print("")
			
			if let error = response.result.error
			{
				if error.domain == NSURLErrorDomain && error.code == -1004
				{
					log.error("No network connection")
					failure?(requestError: .NoConnection)
				} else
				{
					if error.localizedDescription == "cancelled" // TODO: description may change? Use better check for cancellation
					{
						log.error("Cancelled")
						failure?(requestError: .Cancelled)
					} else
					{
						log.error("Error with request to server: \(error.localizedDescription)")
						failure?(requestError: .Other(error.localizedDescription))
					}
				}
			} else
			{
				if let data = response.result.value
				{
					if let contentType = response.response?.allHeaderFields["Content-Type"] as? String
					{
						if let boundaryRange = contentType.rangeOfString("boundary=\"")
						{
							var boundary = "--" + contentType.substringWithRange(Range<String.Index>(start: boundaryRange.endIndex, end: contentType.endIndex))
							boundary = boundary.substringToIndex(boundary.endIndex.predecessor())
							dataResponseHandler?(data: data, multipartBoundary: boundary)
						} else
						{
							dataResponseHandler?(data: data, multipartBoundary: nil)
						}
					} else
					{
						dataResponseHandler?(data: data, multipartBoundary: nil)
					}
				} else
				{
					if let statusCode = response.response?.statusCode
					{
						failure?(requestError: .StatusCode(statusCode: statusCode, message: "Status code != 2xx"))
					} else
					{
						failure?(requestError: .Other("Other error with data response"))
					}

				}
			}
		}
	}
	
	static func makeAuthenticatedRequestToEndpoint(
		endpoint: Endpoint,
		username: String,
		password: String,
		successHandler success: () -> (),
		failureHandler failure: ((requestError: RequestError) -> ())?) -> Alamofire.Request
	{
		return Alamofire.request(
			endpoint.method,
			endpoint.baseURL + endpoint.path,
			parameters: endpoint.parameters,
			encoding: endpoint.encoding,
			headers: endpoint.headers
		).authenticate(
			user: username,
			password: password
		).responseString { (response) -> Void in
			print(" ")
			log.verbose(String(reflecting: response))
			print(" ")
			
			if let error = response.result.error
			{
				if error.domain == NSURLErrorDomain && error.code == -1004
				{
					log.error("No network connection")
					failure?(requestError: .NoConnection)
				} else
				{
					if error.localizedDescription == "cancelled" // TODO: description may change? Use better check for cancellation
					{
						log.error("Cancelled")
						failure?(requestError: .Cancelled)
					} else
					{
						log.error("Error with request to server: \(error.localizedDescription)")
						failure?(requestError: .Other(error.localizedDescription))
					}
				}
			} else
			{
				if response.result.isSuccess
				{
					success()
				} else
				{
					let error = RequestError.Other("Unknown error")
					failure?(requestError: error)
				}
			}
		}
	}
}
