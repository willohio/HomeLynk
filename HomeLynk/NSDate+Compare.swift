//
//  NSDate+Compare.swift
//  HomeLynk
//
//  Created by William Santiago on 3/12/16.
//  Copyright © 2016 William Santiago. All rights reserved.
//

import Foundation

public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
	return lhs === rhs || lhs.compare(rhs) == .OrderedSame
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
	return lhs.compare(rhs) == .OrderedAscending
}

extension NSDate: Comparable { }
