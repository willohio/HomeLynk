//
//  BlockBustaFetcher.swift
//  HomeLynk
//
//  Created by Ivan Dilchovski on 1/20/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
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