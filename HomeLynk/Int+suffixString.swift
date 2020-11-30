//
//  Int+suffixString.swift
//  HomeLynk
//
//  Created by William Santiago on 1/21/16.
//  Copyright © 2016 William Santiago. All rights reserved.
//

import Foundation

extension Int
{
	func suffixString() -> String
	{
		let sign = (self < 0) ? "-" : ""
		if self < 1000
		{
			return "\(sign)\(self)"
		} else
		{
			let exp = Int(log10(Double(self)) / log10(1000))
			let units = ["K", "M", "G", "T", "P", "E"]
			let shortened = Int(Double(self) / pow(1000.0, Double(exp)))
			
			return "\(sign)\(shortened)\(units[exp-1])"
		}
	}
}
