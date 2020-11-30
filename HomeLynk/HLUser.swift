//
//  HLUser.swift
//  HomeLynk
//
//  Created by William Santiago on 1/20/16.
//  Copyright © 2016 William Santiago. All rights reserved.
//

import Foundation

class HLUser
{
	static var currentUser: HLUser?
	static var currentUserAuthToken: String? // Static var, because currentUser is often updated with new objects when receiving updated JSON from server
	
	static let ageRanges  = ["20 or under", "20-24", "25-29", "30-34", "35-39", "40-60", "60+"]
	
	var id:			Int				= -1
	var email:		String?			= nil
	var authToken:	String?			= nil
	var firstName:	String?			= nil
	var lastName:	String?			= nil
	var age:		String?			= nil
	var phone:		String?			= nil
}
