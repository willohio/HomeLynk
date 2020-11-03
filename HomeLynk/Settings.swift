//
//  Settings.swift
//  HomeLynk
//
//  Created by Ivan Dilchovski on 1/25/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation

struct Settings
{
	static let defaults = NSUserDefaults()
	
	struct Device
	{
		private static let pushTokenKey = "defaults.device.pushToken"
		static var pushToken: String?
		{
			get
			{
				return defaults.objectForKey(pushTokenKey) as? String
			}
			
			set
			{
				defaults.setObject(newValue, forKey: pushTokenKey)
			}
		}
	}

	
	struct User
	{
		static var anonymousId: String?
		{
			get
			{
				return defaults.stringForKey(Constants.Keys.kDefaultsUserAnonymousId)
			}
			
			set
			{
				defaults.setObject(newValue, forKey: Constants.Keys.kDefaultsUserAnonymousId)
			}
		}
		
		static var hiddenProperties: [Int]
		{
			get
			{
				if let hidden = defaults.objectForKey(Constants.Keys.kDefaultsHiddenProperties) as? [Int]
				{
					return hidden
				} else
				{
					defaults.setObject([Int](), forKey: Constants.Keys.kDefaultsHiddenProperties)
					return [Int]()
				}
			}
			
			set
			{
				defaults.setObject(newValue, forKey: Constants.Keys.kDefaultsHiddenProperties)
			}
		}
		
		static var blockBustaTipShown: Bool
		{
			get
			{
				return defaults.boolForKey(Constants.Keys.kDefaultsBlockBustaTipShown)
			}
			
			set
			{
				defaults.setBool(newValue, forKey: Constants.Keys.kDefaultsBlockBustaTipShown)
			}
		}
	}
	
	struct General
	{
		static var imagesCacheFolder: NSURL!
	}
}