//
//  UIImage+ImageWithColor.swift
//  HomeLynk
//
//  Created by William Santiago on 1/15/16.
//  Copyright © 2016 William Santiago. All rights reserved.
//

import UIKit

extension UIImage
{
	class func imageWithColor(color: UIColor, size: CGSize) -> UIImage
	{
		let rect = CGRectMake(0, 0, size.width, size.height)
		UIGraphicsBeginImageContextWithOptions(size, false, 0)
		color.setFill()
		UIRectFill(rect)
		let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return image
	}
}
