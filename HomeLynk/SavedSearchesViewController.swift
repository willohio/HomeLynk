//
//  SavedSearchesViewController.swift
//  HomeLynk
//
//  Created by Ivan Dilchovski on 1/21/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import UIKit

class SavedSearchesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
	// MARK: - Properties
	var searches: [HLSearch]?
	{
		didSet
		{
			if activityIndicator != nil && oldValue == nil
			{
				activityIndicator.stopAnimating()
				tableView.reloadData()
			}
		}
	}
	
	var isBlockBusta = false
	
	private var searchesForDeleteButtons = [UIButton : HLSearch]()
	private var searchesForBustaButtons = [UIButton : HLSearch]()
	
	private let labelTitleFontSize: CGFloat = 14.0
	private let labelValueFontSize: CGFloat = 13.0
	
	// MARK: - Outlets
	
	@IBOutlet var activityIndicator: UIActivityIndicatorView!
	@IBOutlet var tableView: UITableView!
	
	
	// MARK: - Actions
	
	func deleteSearch(sender: UIButton)
	{
		let alertController = UIAlertController(title: "Delete saved search?", message: nil, preferredStyle: .Alert)
		let okAction = UIAlertAction(title: "Yes", style: .Destructive) { (action) -> Void in
			//Safe to unwrap. Needs searches to have a delete button
			
			let deletedSearch = self.searchesForDeleteButtons[sender]!
			HLSearchRequest.deleteSavedSearch(deletedSearch,
				successHandler: { () -> () in
					self.searches = self.searches!.filter { $0.id != deletedSearch.id }
					
					self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
				},
				failureHandler: { (requestError) -> () in
					self.presentViewController(requestError.getGenericAlert(), animated: true, completion: nil)
			})
		}
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
		alertController.addAction(okAction)
		alertController.addAction(cancelAction)
		
		self.presentViewController(alertController, animated: true, completion: nil)
	}
	
	func switchBusta(sender: UIButton)
	{
		let search = self.searchesForBustaButtons[sender]!
		let title: String
		if search.isBlockBusta
		{
			title = "Remove from Block Busta?"
		} else
		{
			title = "Add to Block Busta?"
		}
		
		let alertController = UIAlertController(title: title, message: nil, preferredStyle: .Alert)
		let okAction = UIAlertAction(title: "Yes", style: .Default) { (action) -> Void in
			search.isBlockBusta = !search.isBlockBusta
			
			HLSearchRequest.updateSavedSearch(search,
				successHandler: { () -> () in
					self.searches = self.searches!.filter { $0.id != search.id }
					
					self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
				},
				failureHandler: { (requestError) -> () in
					self.presentViewController(requestError.getGenericAlert(), animated: true, completion: nil)
			})
		}
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
		alertController.addAction(okAction)
		alertController.addAction(cancelAction)
		
		self.presentViewController(alertController, animated: true, completion: nil)
	}
	
	// MARK: - Lifecycle
	
    override func viewDidLoad()
	{
        super.viewDidLoad()
		
		self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil) //Removes the title from the back button on the next screen
		
		if !Settings.User.blockBustaTipShown
		{
			Settings.User.blockBustaTipShown = true
			let alertController = UIAlertController(title: nil, message: "BlockBusta is an automated search feature that will notify you as soon as a home that matches your pre-defined search constraints become available. Press the target button next to any search under your Saved Searches to add the search to BlockBusta!", preferredStyle: .Alert)
			let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
			alertController.addAction(okAction)
			
			self.presentViewController(alertController, animated: true, completion: nil)
		}
		
		if let searches = searches
		{
			if isBlockBusta
			{
				self.searches = searches.filter { $0.isBlockBusta }
			} else
			{
				self.searches = searches.filter { !$0.isBlockBusta }
			}
			
		}
		
		if isBlockBusta
		{
			navigationItem.title = "BlockBusta"
		} else
		{
			navigationItem.title = "Saved Searches"
		}
    }

    override func didReceiveMemoryWarning()
	{
        super.didReceiveMemoryWarning()
    }
	
	//MARK: - UITableViewDataSource
	func numberOfSectionsInTableView(tableView: UITableView) -> Int
	{
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		if let searches = searches
		{
			return searches.count
		} else
		{
			return 0
		}
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
	{
		let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIds.savedSearchCell, forIndexPath: indexPath) as! SavedSearchTableCell
		
		let search = searches![indexPath.row] // Should be safe to implicitly unwrap. If nil, numberOfRowsInSection will be 0
		
		searchesForDeleteButtons[cell.deleteButton] = search
		searchesForBustaButtons[cell.bustaButton] = search
		
		if !cell.deleteButton.allTargets().contains(self)
		{
			cell.deleteButton.addTarget(self, action: "deleteSearch:", forControlEvents: .TouchUpInside)
		}
		
		if !cell.bustaButton.allTargets().contains(self)
		{
			cell.bustaButton.addTarget(self, action: "switchBusta:", forControlEvents: .TouchUpInside)
		}
		
		if search.isBlockBusta
		{
			cell.bustaButton.setImage(UIImage(named: "block_busta_icon_blue"), forState: .Normal)
		} else
		{
			cell.bustaButton.setImage(UIImage(named: "block_busta_icon_gray"), forState: .Normal)
		}
		
		cell.titleLabel.text = search.title
		
		let labelColor = cell.propertyTypeLabel.textColor
		
		var priceRange = ""
		if let minPrice = search.minPrice
		{
			priceRange = "$\(minPrice.suffixString())-"
		} else
		{
			priceRange = "$0-"
		}
		
		if let maxPrice = search.maxPrice
		{
			priceRange += "$\(maxPrice.suffixString())"
		}
		
		let paramsText = NSMutableAttributedString()
		
		paramsText.appendAttributedString(NSAttributedString(string: "Price: ",
			attributes: [NSForegroundColorAttributeName : labelColor,
						NSFontAttributeName : UIFont.systemFontOfSize(labelTitleFontSize)]))
		
		paramsText.appendAttributedString(NSAttributedString(string: "\(priceRange) ",
			attributes: [NSForegroundColorAttributeName : Constants.Colors.LightBlue,
						NSFontAttributeName : UIFont.boldSystemFontOfSize(labelValueFontSize)]))
		
		
		paramsText.appendAttributedString(NSAttributedString(string: "Beds: ",
			attributes: [NSForegroundColorAttributeName : labelColor,
				NSFontAttributeName : UIFont.systemFontOfSize(labelTitleFontSize)]))
		
		if let minBeds = search.minBeds
		{
			paramsText.appendAttributedString(NSAttributedString(string: "\(minBeds)+ ",
				attributes: [NSForegroundColorAttributeName : Constants.Colors.LightBlue,
							NSFontAttributeName : UIFont.boldSystemFontOfSize(labelValueFontSize)]))
		} else
		{
			paramsText.appendAttributedString(NSAttributedString(string: "Any ",
				attributes: [NSForegroundColorAttributeName : Constants.Colors.LightBlue,
					NSFontAttributeName : UIFont.boldSystemFontOfSize(labelValueFontSize)]))
		}
		
		paramsText.appendAttributedString(NSAttributedString(string: "Baths: ",
			attributes: [NSForegroundColorAttributeName : labelColor,
				NSFontAttributeName : UIFont.systemFontOfSize(labelTitleFontSize)]))
		
		if let minBaths = search.minBaths
		{
			paramsText.appendAttributedString(NSAttributedString(string: "\(minBaths)+ ",
				attributes: [NSForegroundColorAttributeName : Constants.Colors.LightBlue,
							NSFontAttributeName : UIFont.boldSystemFontOfSize(labelValueFontSize)]))
		} else
		{
			paramsText.appendAttributedString(NSAttributedString(string: "Any ",
				attributes: [NSForegroundColorAttributeName : Constants.Colors.LightBlue,
					NSFontAttributeName : UIFont.boldSystemFontOfSize(labelValueFontSize)]))
		}
		
		paramsText.appendAttributedString(NSAttributedString(string: "SqFt: ",
			attributes: [NSForegroundColorAttributeName : labelColor,
				NSFontAttributeName : UIFont.systemFontOfSize(labelTitleFontSize)]))
		
		if let minSqFt = search.minSqFt where minSqFt != 0
		{
			paramsText.appendAttributedString(NSAttributedString(string: "\(minSqFt) Sq.Ft.",
				attributes: [NSForegroundColorAttributeName : Constants.Colors.LightBlue,
							NSFontAttributeName : UIFont.boldSystemFontOfSize(labelValueFontSize)]))
		} else
		{
			paramsText.appendAttributedString(NSAttributedString(string: "Any",
				attributes: [NSForegroundColorAttributeName : Constants.Colors.LightBlue,
					NSFontAttributeName : UIFont.boldSystemFontOfSize(labelValueFontSize)]))
		}
		
		cell.searchParamsLabel.attributedText = paramsText
		
		if let propertyType = search.propertyType
		{
			cell.propertyTypeLabel.text = propertyType.rawValue
		}
		
		if let savedOn = search.savedOn
		{
			let dateFormatter = NSDateFormatter()
			dateFormatter.dateFormat = "MMM dd yyyy"
			cell.savedOnLabel.text = dateFormatter.stringFromDate(savedOn)
		} else
		{
			let dateFormatter = NSDateFormatter()
			dateFormatter.dateFormat = "MMM dd yyyy"
			cell.savedOnLabel.text = dateFormatter.stringFromDate(NSDate())
		}
		
		if let results = search.results
		{
			cell.totalLabel.text = "\(results)"
		} else
		{
			cell.totalLabel.text = "0"
		}
		
		return cell
	}
	
	// MARK: - UITableViewDelegate
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
	{
		let search = searches![indexPath.row]
		activityIndicator.startAnimating()
		
		// FIXME: Ugly as sin. Same code as in SearchViewController && SavedHomes. Refactor to a common class
		NYRetsProvider.getPropertiesFromHLSearch(
			search,
			successHandler: { (properties) -> () in
				guard properties.count > 0
					else
				{
					self.activityIndicator.stopAnimating()
					
					let alertController = UIAlertController(title: "No properties found", message: nil, preferredStyle: .Alert)
					let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
					alertController.addAction(okAction)
					
					self.presentViewController(alertController, animated: true, completion: nil)
					return
				}
				
				var preloadedResultProperties: [HLProperty]? // Some of the results are directly pre-loaded with slow data - first pic
				var notPreloadedResultProperties: [HLProperty]? // Most are provided, to be fully loaded on demand
				
				var preloadPropertiesDict = [Int : HLProperty]()
				
				let preloadedPropertiesCount = (properties.count <= Constants.Values.propertyListPerLoad) ? properties.count :Constants.Values.propertyListPerLoad
				let preloadedProperties = Array(properties[0..<preloadedPropertiesCount])
				
				for property in preloadedProperties
				{
					preloadPropertiesDict[property.id!] = property
				}
				
				if preloadedPropertiesCount != properties.count
				{
					notPreloadedResultProperties = Array(properties[preloadedPropertiesCount..<properties.count])
				}
				
				NYRetsGetObjectRequest.getPhotosForPropertyIds(
					Array(preloadPropertiesDict.keys),
					firstPhotoOnly: true,
					successHandler: { (photos) -> () in
						for (propertyId, photosData) in photos
						{
							for photoData in photosData
							{
								if let property = preloadPropertiesDict[propertyId], image = UIImage(data: photoData)
								{
									if property.propertyImages == nil
									{
										property.propertyImages = [UIImage]()
									}
									
									property.propertyImages!.append(image)
								}
							}
						}
						
						self.activityIndicator.stopAnimating()
						
						preloadedResultProperties = preloadedProperties
						
						
						let savedHomes = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(Constants.StoryboardIds.ListPropertiesViewController) as! ListPropertiesViewController
						
						savedHomes.listSourceType = .SavedSearchResults
						savedHomes.propertiesWithPreview = preloadedResultProperties
						savedHomes.propertiesWithoutPreview = notPreloadedResultProperties
						savedHomes.search = search
						
						self.activityIndicator.stopAnimating()
						
						self.navigationController?.pushViewController(savedHomes, animated: true)
					},
					failureHandler: { (requestError) -> () in
						self.presentViewController(requestError.getGenericAlert(), animated: true, completion: nil)
				})
			},
			failureHandler: { (requestError) -> () in
				self.activityIndicator.stopAnimating()
				
				self.presentViewController(requestError.getGenericAlert(), animated: true, completion: nil)
		})

	}
}
