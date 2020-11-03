//
//  HLAgent.swift
//  HomeLynk
//
//  Created by Ivan Dilchovski on 2/3/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation

class HLAgent
{
	var id: Int
	var name: String?
	var phone: String?
	var email: String?
	
	init(id: Int, name: String? = nil, phone: String? = nil, email: String? = nil)
	{
		self.id = id
		self.name = name
		self.phone = phone
		self.email = email
	}
}