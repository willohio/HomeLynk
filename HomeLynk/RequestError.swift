//
//  RequestError.swift
//  HomeLynk
//
//  Created by William Santiago on 1/29/16.
//  Copyright © 2016 William Santiago. All rights reserved.
//

import UIKit

enum RequestError
{
	case StatusCode(statusCode: Int, message: String?)
	case BadResponseFormat(String)
	case BadRequest(String)
	case NoConnection
	case Cancelled
	case Other(String)
}

extension RequestError
{
	func getGenericAlert() -> UIAlertController
	{
		switch self
		{
		case .NoConnection:
			let alertController = UIAlertController(title: "No connection to server", message: nil, preferredStyle: .Alert)
			let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
			alertController.addAction(okAction)
			
			return alertController
			
		case .StatusCode(let statusCode, _):
			if statusCode == 401
			{
				let alertController = UIAlertController(title: "Wrong credentials", message: nil, preferredStyle: .Alert)
				let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
				alertController.addAction(okAction)
				
				return alertController
			} else if statusCode == 403
			{
				let alertController = UIAlertController(title: "You are not authorized to do this.", message: nil, preferredStyle: .Alert)
				let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
				alertController.addAction(okAction)
				
				return alertController
			} else if statusCode == 422 //Unprocessable Entity
			{
				let alertController = UIAlertController(title: "There was an error with the request", message: nil, preferredStyle: .Alert)
				let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
				alertController.addAction(okAction)
				
				return alertController
			} else
			{
				let alertController = UIAlertController(title: "Error in communication with server", message: "Please try again later.", preferredStyle: .Alert)
				let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
				alertController.addAction(okAction)
				
				return alertController
			}
			
		default:
			let alertController = UIAlertController(title: "Error in communication with server", message: "Please try again later.", preferredStyle: .Alert)
			let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
			alertController.addAction(okAction)
			
			return alertController
		}
	}
}
