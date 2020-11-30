//
//  ListPropertiesViewController.swift
//  HomeLynk
//
//  Created by William Santiago on 1/12/16.
//  Copyright © 2016 William Santiago. All rights reserved.
//

import UIKit

enum PropertiesListSource: String
{
	case SavedHomes = "Saved Homes"
	case SearchResults = "Search Results"
	case SavedSearchResults = "Saved Search"
}

class ListPropertiesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
	// MARK: - Properties
	
	var propertiesWithPreview: [HLProperty]? //Properties with the first photo loaded from db
	{
		didSet
		{
			//Observer can be called before IB outlets are set
			if activityIndicator != nil && tableView != nil && oldValue == nil
			{
				activityIndicator.stopAnimating()
				tableView.reloadData()
			}
		}
	}
	
	var propertiesWithoutPreview: [HLProperty]? //Properties with the first photo not loaded yet
	{
		didSet
		{
			if tableView != nil && oldValue == nil
			{
				self.loadMoreProperties()
			}
		}
	}
	
	var listSourceType: PropertiesListSource?
	var search: HLSearch? // The search used to populate this list
	
	private var isLoadingMore = false
	
	// MARK: - Outlets
	
	@IBOutlet var sortButton: UIButton!
	@IBOutlet var mapButton: UIButton!
	@IBOutlet var saveSearchButton: UIButton!
	
	@IBOutlet var tableView: UITableView!
	@IBOutlet var activityIndicator: UIActivityIndicatorView!
	
	// MARK: - Actions
	
	@IBAction func sortPressed(sender: UIButton)
	{
		let alert = UIAlertController(title: "Sort by", message: nil, preferredStyle: .ActionSheet)
		
		let priceAsc = UIAlertAction(title: "Price (low to high)", style: .Default) { (action) -> Void in
			self.propertiesWithPreview?.sortInPlace { $0.price < $1.price }
			self.tableView.reloadData()
		}
		
		let priceDesc = UIAlertAction(title: "Price (high to low)", style: .Default) { (action) -> Void in
			self.propertiesWithPreview?.sortInPlace { $0.price > $1.price }
			self.tableView.reloadData()
		}
		
		let newest = UIAlertAction(title: "Newest", style: .Default) { (action) -> Void in
			self.propertiesWithPreview?.sortInPlace { $0.listDate > $1.listDate }
			self.tableView.reloadData()
		}
		
		let area = UIAlertAction(title: "Square feet", style: .Default) { (action) -> Void in
			self.propertiesWithPreview?.sortInPlace { $0.lotSize > $1.lotSize }
			self.tableView.reloadData()
		}
		
		let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
		
		alert.addAction(priceAsc)
		alert.addAction(priceDesc)
		alert.addAction(newest)
		alert.addAction(area)
		alert.addAction(cancel)
		
		self.presentViewController(alert, animated: true, completion: nil)
	}
	
	@IBAction func saveSearchPressed(sender: UIButton)
	{
		guard let search = search
			else
		{
			return
		}
		
		HLSearchRequest.saveSearch(search, successHandler: { () -> () in
			let alertController = UIAlertController(title: "Search saved", message: nil, preferredStyle: .Alert)
			let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
			alertController.addAction(okAction)
			
			self.presentViewController(alertController, animated: true, completion: nil)
			}) { (error) -> () in
				self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
		}
	}
	
	@IBAction func mapPressed(sender: UIButton)
	{
		let mapVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(Constants.StoryboardIds.MapViewController) as! MapViewController

		mapVC.isNotHomeScreen = true
		mapVC.properties = propertiesWithPreview
		self.navigationController?.pushViewController(mapVC, animated: true)
		
		mapVC.navigationItem.rightBarButtonItem = nil
	}
	// MARK: - Lifecycle
	
	override func viewDidLoad()
	{
        super.viewDidLoad()
		
		self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil) //Removes the title from the back button on the next screen
		
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 60 //PropertyView.xib label container
		
		if propertiesWithPreview == nil
		{
			activityIndicator.startAnimating()
			
			if propertiesWithoutPreview != nil
			{
				self.loadMoreProperties()
			}
		}
		
		if let listSourceType = listSourceType
		{
			self.navigationItem.title = listSourceType.rawValue
			
			//Only searches can be saved
			if listSourceType != .SearchResults
			{
				saveSearchButton.removeFromSuperview()
			}
		} else
		{
			log.warning("No source type (block busta, search, saved, etc) set for ListPropertiesViewController")
		}
    }

	override func viewWillAppear(animated: Bool)
	{
		super.viewWillAppear(animated)
		
		if let properties = self.propertiesWithPreview
		{
			self.propertiesWithPreview = properties.filter { !Settings.User.hiddenProperties.contains($0.id!) }
		}
	}
	
	override func didReceiveMemoryWarning()
	{
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
	{
		if let segueId = segue.identifier
		{
			if let destVC = segue.destinationViewController as? PropertyViewController,
				sender = sender as? PropertyResultTableCell,
				index = tableView.indexPathForCell(sender),
				properties = propertiesWithPreview
				where segueId == Constants.SegueIds.listPropertiesToPropertyView
					|| segueId == Constants.SegueIds.bustaToPropertiesView
			{
				destVC.property = properties[index.row]
			} else if let destVC = segue.destinationViewController as? MapViewController
				where segueId == Constants.SegueIds.listPropertiesToMap
			{
				destVC.properties = self.propertiesWithPreview
			}
		}
	}
	
	// MARK: - UITableViewDataSource
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
	{
		if indexPath.section == 0
		{
			if let properties = propertiesWithPreview
			{
				if let image = properties[indexPath.row].propertyImages?.first
				{
					return self.view.frame.width / (image.size.width / image.size.height)
				} else
				{
					return tableView.estimatedRowHeight
				}
			} else
			{
				return 59 //Height of label container in IB of PropertyView.xib
			}
		} else
		{
			return 59
		}
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int
	{
		return isLoadingMore ? 2 : 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		if section == 0
		{
			if let properties = propertiesWithPreview
			{
				return properties.count
			} else
			{
				return 0
			}
		} else
		{
			return 1
		}
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
	{
		if indexPath.section == 0
		{
			let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIds.propertyResultTableCell, forIndexPath: indexPath) as! PropertyResultTableCell
			let property = propertiesWithPreview![indexPath.row]
			
			cell.propertyView.setupForProperty(property)
			
			//Start preloading next bach of results if less than 33% of one load are left
			if let notLoaded = propertiesWithoutPreview
				where (propertiesWithPreview!.count - indexPath.row) <= Int(ceil(Double(Constants.Values.propertyListPerLoad) * 0.33)) &&
					notLoaded.count > 0
					&& !isLoadingMore
			{
				self.loadMoreProperties()
			}
			
			return cell
		} else
		{
			return tableView.dequeueReusableCellWithIdentifier(Constants.CellIds.propertySearchTableCell, forIndexPath: indexPath)
		}
	}
	
	// MARK: - UITableViewDelegate
	func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
	{
		if let listSourceType = listSourceType where listSourceType == .SavedHomes && indexPath.section == 0
		{
			return true
		} else
		{
			return false
		}
	}
	
	func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
	{
		if editingStyle == .Delete
		{
			if let listSourceType = listSourceType where listSourceType == .SavedHomes
			{
				let property = propertiesWithPreview![indexPath.row]
				
				HLUsersSavedPropertiesRequest.deleteSavedProperty(property.id!,
					successHandler: { () -> () in
						log.info("Saved property deleted")
						
						self.propertiesWithPreview = self.propertiesWithPreview?.filter { $0.id! != property.id! }
						tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
					}, failureHandler: { (error) -> () in
						self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
				})
			}
		}
	}
	
	// MARK: - Private
	
	private func loadMoreProperties()
	{
		guard let notLoaded = propertiesWithoutPreview
			where notLoaded.count > 0 &&
				!isLoadingMore
			else
		{
			log.info("No more properties to load")
			return
		}
		
		isLoadingMore = true
		
		self.tableView.reloadData() // Show loading indicator section
		
		var preloadedPropertiesDict = [Int : HLProperty]()
		let preloadedPropertiesCount = (notLoaded.count <= Constants.Values.propertyListPerLoad) ? notLoaded.count :Constants.Values.propertyListPerLoad
		let newProperties = notLoaded[0..<preloadedPropertiesCount]
		
		for property in newProperties
		{
			preloadedPropertiesDict[property.id!] = property
		}
		
		if propertiesWithPreview == nil
		{
			propertiesWithPreview = [HLProperty]()
		}
		
		NYRetsGetObjectRequest.getPhotosForPropertyIds(Array(preloadedPropertiesDict.keys),
			firstPhotoOnly: true,
			successHandler: { (photos) -> () in
				for (propertyId, photosData) in photos
				{
					for photoData in photosData
					{
						if let property = preloadedPropertiesDict[propertyId], image = UIImage(data: photoData)
						{
							if property.propertyImages == nil
							{
								property.propertyImages = [UIImage]()
							}
							
							property.propertyImages!.append(image)
						}
					}
				}
				
				self.propertiesWithPreview!.appendContentsOf(Array(preloadedPropertiesDict.values))
				
				if preloadedPropertiesCount != notLoaded.count
				{
					self.propertiesWithoutPreview = Array(notLoaded[preloadedPropertiesCount..<notLoaded.count])
				} else
				{
					self.propertiesWithoutPreview = nil
				}
				
				self.isLoadingMore = false
				self.tableView.reloadData()
			},
			failureHandler: { (requestError) -> () in
				
		})

	}
	
}
