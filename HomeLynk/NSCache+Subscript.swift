//
//  NSCache+Subscript.swift
//  HomeLynk
//
//  Created by William Santiago on 2/26/16.
//  Copyright © 2016 William Santiago. All rights reserved.
//

import Foundation

// http://nshipster.com/nscache/

extension NSCache
{
	subscript(key: AnyObject) -> AnyObject?
	{
		get
		{
			return objectForKey(key)
		}
		set
		{
			if let value: AnyObject = newValue
			{
				setObject(value, forKey: key)
			} else
			{
				removeObjectForKey(key)
			}
		}
	}
}
