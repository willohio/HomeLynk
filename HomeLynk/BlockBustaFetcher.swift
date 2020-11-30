//
//  BlockBustaFetcher.swift
//  HomeLynk
//
//  Created by William Santiago on 1/20/16.
//  Copyright © 2016 William Santiago. All rights reserved.
//

import Foundation

class BlockBustaFetcher
{
	class func getBlockBusta(completionHandler: (([HLProperty]) -> ())?)
	{
		if let completionHandler = completionHandler
		{
			completionHandler([HLProperty]())
		}
	}
}
