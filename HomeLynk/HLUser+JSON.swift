//
//  HLUser+JSON.swift
//  HomeLynk
//
//  Created by Ivan Dilchovski on 2/20/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation
import SwiftyJSON

extension HLUser
{
	convenience init?(json: JSON)
	{
		guard let id = json["id"].int
			else
		{
			log.error("No id in user JSON")
			return nil
		}
		
		self.init()
		
		self.id = id
		self.email = json["email"].string
		self.authToken = json["token"].string
		self.firstName = json["firstname"].stringValue
		self.lastName = json["lastname"].stringValue
		self.age = json["age"].string
		self.phone = json["phone"].string
	}

}