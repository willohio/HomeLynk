//
//  NSCache+Subscript.swift
//  HomeLynk
//
//  Created by Ivan Dilchovski on 2/26/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
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