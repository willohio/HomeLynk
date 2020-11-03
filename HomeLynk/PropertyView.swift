//
//  PropertyView.swift
//  HomeLynk
//
//  Created by Ivan Dilchovski on 1/15/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import UIKit

import Alamofire

class PropertyView: UIView
{
	var rootView: UIView!
	var property: HLProperty!
	
	private var propertyImageRequest: Alamofire.Request?
	
	@IBOutlet var propertyImage: UIImageView!
	@IBOutlet var propertyImageHeight: NSLayoutConstraint! // Low priority constraint. Can be set so that the image is the correct aspect ratio.
	// NOTE: If not countered by an outside constraint on the view container, it can grow larger than the screen for tall images
	
	@IBOutlet var labelsContainer: UIView!
	
	@IBOutlet var priceLabel: UILabel!
	@IBOutlet var addressLabel: UILabel!
	@IBOutlet var bedsLabel: UILabel!
	@IBOutlet var bathsLabel: UILabel!
	@IBOutlet var sizeLabel: UILabel!
	@IBOutlet var address2Label: UILabel!
	
	@IBOutlet var activityIndicatorHeight: NSLayoutConstraint!
	@IBOutlet var activityIndicator: UIActivityIndicatorView!
	
	required init?(coder aDecoder: NSCoder)
	{
		super.init(coder: aDecoder)
		
		let views = NSBundle.mainBundle().loadNibNamed("PropertyView", owner: self, options: nil)
		
		if let view = views[0] as? UIView
		{
			rootView = view
			rootView.translatesAutoresizingMaskIntoConstraints = false
			self.addSubview(rootView)
			var constraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[rootView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["rootView" : rootView])
			constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|[rootView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["rootView" : rootView])
			
			NSLayoutConstraint.activateConstraints(constraints)

		}
	}
	
	func setupForProperty(property: HLProperty)
	{
		self.property = property
		
		priceLabel.attributedText = makePriceStringForPrice(property.price)
		addressLabel.text = property.address
		bedsLabel.attributedText = makeBedsStringForBeds(property.beds)
		bathsLabel.attributedText = makeBathsStringForBaths(property.baths)
		sizeLabel.attributedText = makeSizeStringForSize(property.size)
		
		if let propertyType = property.propertyType
		{
			switch propertyType
			{
				case .CondoTownhouse: address2Label.text = "CND"
				case .Land: address2Label.text = "LND"
				case .SingleFamily: address2Label.text = "SFH"
				case .MultiFamily: address2Label.text = "MFH"
				
				default: address2Label.text = nil
			}
		}
		
		if let image = property.propertyImages?.first
		{
			activityIndicator.stopAnimating()
			propertyImage.image = image
			
			UIView.animateWithDuration(Constants.Values.animationDurationShort) { () -> Void in
				self.propertyImageHeight.constant = self.frame.width * (image.size.height / image.size.width)
			}
		} else
		{
			if let id = property.id
			{
				activityIndicator.startAnimating()
				activityIndicatorHeight.constant = 20
				
				self.propertyImage.image = nil
				UIView.animateWithDuration(Constants.Values.animationDurationShort) { () -> Void in
					self.propertyImageHeight.constant = 0
				}
				
				propertyImageRequest?.cancel()
				propertyImageRequest = NYRetsGetObjectRequest.getPhotosForPropertyIds([id],
					firstPhotoOnly: true,
					successHandler: { (photos) -> () in
						self.activityIndicator.stopAnimating()
						self.activityIndicatorHeight.constant = 0
						
						self.propertyImageRequest = nil
						
						if let data = photos[id]?.first, image = UIImage(data: data)
						{
							UIView.animateWithDuration(Constants.Values.animationDurationShort) { () -> Void in
								self.propertyImageHeight.constant = self.frame.width * (image.size.height / image.size.width)
								self.propertyImage.image = image
								self.property.propertyImages = [image]
							}
						}
					},
					failureHandler: { (requestError) -> () in
						self.activityIndicator.stopAnimating()
						self.activityIndicatorHeight.constant = 0
						self.propertyImageRequest = nil
						log.error("Could not get image for property")
				})
			}
		}
	}
	
	private func makePriceStringForPrice(price: Int?) -> NSAttributedString
	{
		let formatter = NSNumberFormatter()
		formatter.numberStyle = .DecimalStyle
		
		let attributedString: NSMutableAttributedString
		
		if let price = price
		{
			attributedString = NSMutableAttributedString(string: "$\(formatter.stringFromNumber(price)!)")
		} else
		{
			attributedString = NSMutableAttributedString(string: "n/a")
		}
		
		attributedString.setAttributes([NSFontAttributeName : UIFont.boldSystemFontOfSize(17)],
			range: NSMakeRange(0, attributedString.length))
		
		return attributedString
	}
	
	private func makeSizeStringForSize(size: Double?) -> NSAttributedString
	{
		let formatter = NSNumberFormatter()
		formatter.numberStyle = .DecimalStyle
		
		let attributedString: NSMutableAttributedString
		
		if let size = size
		{
			attributedString = NSMutableAttributedString(string: formatter.stringFromNumber(size)!)
		} else
		{
			attributedString = NSMutableAttributedString(string: "n/a")
		}
		
		var range = NSMakeRange(0, attributedString.length)
		attributedString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(16), range: range)
		attributedString.appendAttributedString(NSAttributedString(string: " \(Constants.Strings.areadUnits)"))
		range = NSMakeRange(range.length, attributedString.length - range.length)
		attributedString.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(15), range: range)
		
		return attributedString
	}
	
	private func makeBedsStringForBeds(beds: Int?) -> NSAttributedString
	{
		let attributedString: NSMutableAttributedString
		
		if let beds = beds
		{
			attributedString = NSMutableAttributedString(string: "\(beds)")
		} else
		{
			attributedString = NSMutableAttributedString(string: "n/a")
		}

		var range = NSMakeRange(0, attributedString.length)
		attributedString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(16), range: range)
		attributedString.appendAttributedString(NSAttributedString(string: " beds"))
		range = NSMakeRange(range.length, attributedString.length - range.length)
		attributedString.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(15), range: range)
		
		return attributedString
	}
	
	private func makeBathsStringForBaths(baths: Int?) -> NSAttributedString
	{
		let attributedString: NSMutableAttributedString
		
		if let baths = baths
		{
			attributedString = NSMutableAttributedString(string: "\(baths)")
		} else
		{
			attributedString = NSMutableAttributedString(string: "n/a")
		}
		
		var range = NSMakeRange(0, attributedString.length)
		attributedString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(16), range: range)
		attributedString.appendAttributedString(NSAttributedString(string: " baths"))
		range = NSMakeRange(range.length, attributedString.length - range.length)
		attributedString.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(15), range: range)
		
		return attributedString
	}
}
