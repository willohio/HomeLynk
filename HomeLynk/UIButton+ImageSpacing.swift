//
//  UIButton+ImageSpacing.swift
//  HomeLynk
//
//  Created by William Santiago on 1/14/16.
//  Copyright © 2016 William Santiago. All rights reserved.
//

import UIKit

extension UIButton
{
	func setImageSpacing(spacing: CGFloat)
	{
		self.imageEdgeInsets = UIEdgeInsets(top: 0, left: -spacing, bottom: 0, right: spacing)
		self.titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: -spacing)
		self.contentEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: spacing)
	}
}
