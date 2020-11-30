//
//  Swift+IsEmail.swift
//  HomeLynk
//
//  Created by William Santiago on 1/25/16.
//  Copyright © 2016 William Santiago. All rights reserved.
//

import Foundation

extension String
{
	var isEmail: Bool
	{
		do
		{
			let regex = try NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .CaseInsensitive)
			return regex.firstMatchInString(self, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count)) != nil
		} catch
		{
			return false
		}
	}
}
