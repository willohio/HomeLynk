//
//  UIButton+TitleUnder.swift
//  HomeLynk
//
//  Created by William Santiago on 1/28/16.
//  Copyright © 2016 William Santiago. All rights reserved.
//

import UIKit

extension UIButton
{
	func moveTitleUnderImageWithPadding(padding: CGFloat)
	{
		let imageSize = self.imageView!.frame.size
		let titleSize = self.titleLabel!.frame.size
		
		let totalHeight = imageSize.height + titleSize.height + padding
		
		self.imageEdgeInsets = UIEdgeInsetsMake(-(totalHeight - imageSize.height), 0, 0, -titleSize.width)
		self.titleEdgeInsets = UIEdgeInsetsMake(0, -imageSize.width, -(totalHeight - titleSize.height), 0)
	}
}
