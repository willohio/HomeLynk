//
//  SearchViewController.swift
//  HomeLynk
//
//  Created by Ivan Dilchovski on 1/12/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import UIKit
import CoreLocation

import Alamofire

import TTRangeSlider

import HNKGooglePlacesAutocomplete
import LMGeocoder

enum PickerState
{
	case SaleRent
	case PropertyType
	case SqFt
	case Lot
	case Year
	case ListedWithin
	
	static let allValues = [SaleRent, PropertyType, SqFt, Lot, Year, ListedWithin]
}

// TODO: Kill Massive View Controller

//Why not just UITableView with static cells? Must be UITableViewController for static cells. Harder to customize the look
class SearchViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, TTRangeSliderDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate
{
	var zipsToSearch: [Int]? // Zip addresses to be used as default location filter, unless the user manually looks for an address
	
	// MARK: - Properties
	
	private var getPropertiesRequest: Alamofire.Request?
	private var getPicturesRequest: Alamofire.Request?
	
	private var search = HLSearch()
	
	private var preloadedResults: [HLProperty]? // Some of the results are directly pre-loaded with slow data - first pic
	private var notPreloadedResults: [HLProperty]? // Most are provided, to be fully loaded on demand

	
	private var locationAutocompleteSuggestions = [HNKGooglePlacesAutocompletePlace]()
	
	private var pickerState = PickerState.PropertyType
	private var selectedPickerRowForState = [PickerState : Int]()
	
	private let decimalFormatter = NSNumberFormatter()
	
	private var oldPriceSelectedMin:Float = 0
	private var oldPriceSelectedMax: Float = 0

	
	// MARK: - Search Options
	private let minLot = [0, 2000, 3000, 4000, 5000, 7500, 10000, 12500, 15000, 20000, 21780, 43560, 87120, 217800, 435600] //Sq Ft
	private let acres = [21780 : "1/2 Acre", 43560 : "1 Acre", 87120 : "2 Acres", 217800 : "5 Acres", 435600 : "10 Acres"] //Look up table for human readable number of acres with the number of Sq Ft as a key
	
	private let minSqFts = [0, 500, 750, 1000, 1250, 1500, 1750, 2000, 2250, 2500, 2750, 3000, 4000]
	private let minYear = Array([1850, 1860, 1870, 1880, 1890, 1900, 1910, 1920, 1930, 1940, 1950, 1960, 1970, 1980, 1990, 1995, 1996, 1997, 1998, 1999, 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016, 0].reverse())
	
	// MARK: - Outlets
	@IBOutlet var separatorHeightConstraints: [NSLayoutConstraint]! //IB rounds points to whole numbers, so set constant manually in code (Note - on non-retina (iPad 2, iPad Mini 1) this may mis-align!
	
	@IBOutlet var addressSearch: UISearchBar!
	@IBOutlet var searchAutocompleteTable: UITableView!
	
	@IBOutlet var priceSlider: TTRangeSlider!
	@IBOutlet var sliderLowLabel: UILabel!
	@IBOutlet var sliderHighLabel: UILabel!
	
	@IBOutlet var bedsSegment: UISegmentedControl!
	@IBOutlet var bathsSegment: UISegmentedControl!
	
	@IBOutlet var pickerView: UIPickerView!
	@IBOutlet var pickerShowConstraint: NSLayoutConstraint!
	@IBOutlet var pickerHideConstraint: NSLayoutConstraint!
	
	@IBOutlet var propertyButtons: [UIButton]! //Add spacing between image and label and move image on right side
	@IBOutlet var listingTypeButton: UIButton!
	@IBOutlet var propertyTypeButton: UIButton!
	@IBOutlet var minSqFtButton: UIButton!
	@IBOutlet var minLotButton: UIButton!
	@IBOutlet var minYearButton: UIButton!
	@IBOutlet var listedWithinButton: UIButton!
	
	@IBOutlet var findHomesButton: UIButton!
	
	@IBOutlet var activityIndicator: UIActivityIndicatorView!
	
	
	// MARK: - Actions
	
	@IBAction func resetPressed(sender: UIBarButtonItem)
	{
		search = HLSearch()
		
		search.zips = zipsToSearch
		
		preloadedResults = nil
		notPreloadedResults = nil
		
		for key in Array(selectedPickerRowForState.keys)
		{
			selectedPickerRowForState[key] = 0
		}
		
		locationAutocompleteSuggestions.removeAll()
		
		addressSearch.text = nil
		
		priceSlider.selectedMinimum = priceSlider.minValue
		priceSlider.selectedMaximum = priceSlider.maxValue
		sliderLowLabel.text = "Price"
		sliderHighLabel.text = "Any Price"
		
		bedsSegment.selectedSegmentIndex = 0
		bathsSegment.selectedSegmentIndex = 0
		
		listingTypeButton.setTitle(HLSearch.ListingType.allValues[0].rawValue, forState: .Normal)
		propertyTypeButton.setTitle(HLProperty.PropertyType.allValues[0].rawValue, forState: .Normal)
		minSqFtButton.setTitle("Any", forState: .Normal)
		minLotButton.setTitle("Any", forState: .Normal)
		minYearButton.setTitle("Any", forState: .Normal)
		listedWithinButton.setTitle(HLSearch.ListingAge.allValues[0].rawValue, forState: .Normal)
		
	}
	
	@IBAction func bedsChanged(sender: UISegmentedControl)
	{
		search.minBeds = bedsSegment.selectedSegmentIndex
	}
	
	@IBAction func bathsChanged(sender: UISegmentedControl)
	{
		search.minBaths = bathsSegment.selectedSegmentIndex
	}
	
	@IBAction func saleRentPressed(sender: UIButton)
	{
		pickerState = .SaleRent
		pickerView.reloadAllComponents()
		pickerView.selectRow(selectedPickerRowForState[pickerState]!, inComponent: 0, animated: false)
		
		if pickerHideConstraint.active
		{
			pickerHideConstraint.active = false
			pickerShowConstraint.active = true
			
			UIView.animateWithDuration(Constants.Values.animationDurationShort) { () -> Void in
				self.view.layoutIfNeeded()
			}
		}
	}
	
	@IBAction func propertyTypesPressed(sender: UIButton)
	{
		pickerState = .PropertyType
		pickerView.reloadAllComponents()
		pickerView.selectRow(selectedPickerRowForState[pickerState]!, inComponent: 0, animated: false)
		
		if pickerHideConstraint.active
		{
			pickerHideConstraint.active = false
			pickerShowConstraint.active = true
			
			UIView.animateWithDuration(Constants.Values.animationDurationShort) { () -> Void in
				self.view.layoutIfNeeded()
			}
		}
	}

	@IBAction func minSqFtPressed(sender: UIButton)
	{
		pickerState = .SqFt
		pickerView.reloadAllComponents()
		pickerView.selectRow(selectedPickerRowForState[pickerState]!, inComponent: 0, animated: false)
		
		if pickerHideConstraint.active
		{
			pickerHideConstraint.active = false
			pickerShowConstraint.active = true
			
			UIView.animateWithDuration(Constants.Values.animationDurationShort) { () -> Void in
				self.view.layoutIfNeeded()
			}
		}
	}
	
	@IBAction func minLotPressed(sender: UIButton)
	{
		pickerState = .Lot
		pickerView.reloadAllComponents()
		pickerView.selectRow(selectedPickerRowForState[pickerState]!, inComponent: 0, animated: false)
		
		if pickerHideConstraint.active
		{
			pickerHideConstraint.active = false
			pickerShowConstraint.active = true
			
			UIView.animateWithDuration(Constants.Values.animationDurationShort) { () -> Void in
				self.view.layoutIfNeeded()
			}
		}
	}
	
	@IBAction func minYearPressed(sender: UIButton)
	{
		pickerState = .Year
		pickerView.reloadAllComponents()
		pickerView.selectRow(selectedPickerRowForState[pickerState]!, inComponent: 0, animated: false)
		
		if pickerHideConstraint.active
		{
			pickerHideConstraint.active = false
			pickerShowConstraint.active = true
			
			UIView.animateWithDuration(Constants.Values.animationDurationShort) { () -> Void in
				self.view.layoutIfNeeded()
			}
		}
	}
	
	@IBAction func listedWithingPressed(sender: UIButton)
	{
		pickerState = .ListedWithin
		pickerView.reloadAllComponents()
		pickerView.selectRow(selectedPickerRowForState[pickerState]!, inComponent: 0, animated: false)
		
		if pickerHideConstraint.active
		{
			pickerHideConstraint.active = false
			pickerShowConstraint.active = true
			
			UIView.animateWithDuration(Constants.Values.animationDurationShort) { () -> Void in
				self.view.layoutIfNeeded()
			}
		}
	}
	
	@IBAction func pickerDonePressed(sender: UIButton)
	{
		if pickerShowConstraint.active
		{
			pickerShowConstraint.active = false
			pickerHideConstraint.active = true
			
			UIView.animateWithDuration(Constants.Values.animationDurationShort) { () -> Void in
				self.view.layoutIfNeeded()
			}
		}
	}
	
	// MARK: Start Search
	
	@IBAction func findHomesPressed(sender: UIButton)
	{
		activityIndicator.startAnimating()
		
		// FIXME: Same code as in SavedSearchesViewController. Refactor to a common class
		
		// First get properties for search
		
		getPropertiesRequest?.cancel()
		getPicturesRequest?.cancel()
		
		getPropertiesRequest = NYRetsProvider.getPropertiesFromHLSearch(
			search,
			successHandler: { (properties) -> () in
				defer
				{
					self.getPropertiesRequest = nil
				}
				
				guard properties.count > 0
					else
				{
					self.activityIndicator.stopAnimating()
					
					let alertController = UIAlertController(title: "No Properties Found. Save Search?", message: nil, preferredStyle: .Alert)
					let yesAction = UIAlertAction(title: "Yes", style: .Default) { (action) -> Void in
						let alertController = UIAlertController(title: "Add Search to BlockBusta?", message: nil, preferredStyle: .Alert)
						let yesAction = UIAlertAction(title: "Yes", style: .Default) { (action) -> Void in
							self.search.isBlockBusta = true
							HLSearchRequest.saveSearch(self.search, successHandler: { () -> () in
								let alertController = UIAlertController(title: "BlockBusta search saved.", message: nil, preferredStyle: .Alert)
								let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
								alertController.addAction(okAction)
								
								self.presentViewController(alertController, animated: true, completion: nil)
								}) { (error) -> () in
									self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
							}

						}
						let noAction = UIAlertAction(title: "No", style: .Default) { (action) -> Void in
							self.search.isBlockBusta = false
							HLSearchRequest.saveSearch(self.search, successHandler: { () -> () in
								let alertController = UIAlertController(title: "Search saved.", message: nil, preferredStyle: .Alert)
								let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
								alertController.addAction(okAction)
								
								self.presentViewController(alertController, animated: true, completion: nil)
								}) { (error) -> () in
									self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
							}
						}
						
						alertController.addAction(yesAction)
						alertController.addAction(noAction)
						
						self.presentViewController(alertController, animated: true, completion: nil)
					}
					
					let noAction = UIAlertAction(title: "No", style: .Default, handler: nil)
					
					alertController.addAction(yesAction)
					alertController.addAction(noAction)
					
					self.presentViewController(alertController, animated: true, completion: nil)
					return
				}
				
				// Now preload the first image for a number of properties to be shown to the user directly
				
				var preloadPropertiesDict = [Int : HLProperty]()
				let preloadedPropertiesCount = (properties.count <= Constants.Values.propertyListPerLoad) ? properties.count :Constants.Values.propertyListPerLoad
				let preloadedProperties = Array(properties[0..<preloadedPropertiesCount])
				
				for property in preloadedProperties
				{
					preloadPropertiesDict[property.id!] = property
				}
				
				if preloadedPropertiesCount != properties.count
				{
					self.notPreloadedResults = Array(properties[preloadedPropertiesCount..<properties.count])
				} else
				{
					self.notPreloadedResults = nil
				}
				
				self.getPicturesRequest = NYRetsGetObjectRequest.getPhotosForPropertyIds(
					Array(preloadPropertiesDict.keys),
					firstPhotoOnly: true,
					successHandler: { (photos) -> () in
						defer
						{
							self.getPicturesRequest = nil
						}
				
						
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
						
						self.preloadedResults = preloadedProperties
						self.performSegueWithIdentifier(Constants.SegueIds.searchToListResults, sender: nil) // Go to results only after the first images have been preloaded for a bunch of properties
					},
					failureHandler: { (requestError) -> () in
						switch requestError // requestError can not be directly compared with .Cancelled due to associated values in the enum cases
						{
							case .Cancelled: ()
							default: self.presentViewController(requestError.getGenericAlert(), animated: true, completion: nil)
						}
						self.getPicturesRequest = nil
				})
			},
			failureHandler: { (requestError) -> () in
				self.activityIndicator.stopAnimating()
				
				switch requestError // requestError can not be directly compared with .Cancelled due to associated values in the enum cases
				{
					case .Cancelled: ()
					default: self.presentViewController(requestError.getGenericAlert(), animated: true, completion: nil)
				}
				
				self.getPropertiesRequest = nil
		})
	}
	
	
	// MARK: - Lifecycle
	
    override func viewDidLoad()
	{
        super.viewDidLoad()
		
		self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil) //Removes the title from the back button on the next screen
		
		search.zips = zipsToSearch
		
		priceSlider.hideLabels = true
		priceSlider.enableStep = true
		
		for constraint in separatorHeightConstraints
		{
			constraint.constant = 0.5
		}
		
		findHomesButton.layer.cornerRadius = 5
		
		for button in propertyButtons
		{
			//Add spacing between button and image
			button.setImageSpacing(8)
			
			//Flip button and image
			button.transform = CGAffineTransformMakeScale(-1.0, 1.0);
			button.titleLabel!.transform = CGAffineTransformMakeScale(-1.0, 1.0);
			button.imageView!.transform = CGAffineTransformMakeScale(-1.0, 1.0);
		}
		
		decimalFormatter.numberStyle = .DecimalStyle
		
		for pickerState in PickerState.allValues
		{
			selectedPickerRowForState[pickerState] = 0
		}
		
		priceSlider.delegate = self
		addressSearch.delegate = self
    }

	override func viewWillDisappear(animated: Bool)
	{
		super.viewWillDisappear(animated)
		
		getPropertiesRequest?.cancel()
		getPicturesRequest?.cancel()
	}
	
    override func didReceiveMemoryWarning()
	{
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
	{
		if let segueId = segue.identifier, destVC = segue.destinationViewController as? ListPropertiesViewController
			where segueId == Constants.SegueIds.searchToListResults
		{
			destVC.propertiesWithPreview = self.preloadedResults
			destVC.propertiesWithoutPreview = self.notPreloadedResults
			destVC.search = self.search
			
			destVC.listSourceType = .SearchResults
		}
	}

	// MARK: - UIPickerViewDataSource
	
	func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int
	{
		return 1
	}
	
	func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
	{
		switch self.pickerState
		{
			case .SaleRent: return HLSearch.ListingType.allValues.count
			
			case .PropertyType: return HLProperty.PropertyType.allValues.count
			
			case .SqFt: return minSqFts.count
			
			case .Lot: return minLot.count
			
			case .Year: return minYear.count
			
			case .ListedWithin: return HLSearch.ListingAge.allValues.count
		}
	}
	
	func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
	{
		switch pickerState
		{
			case .SaleRent: return HLSearch.ListingType.allValues[row].rawValue
			
			case .PropertyType: return HLProperty.PropertyType.allValues[row].rawValue
			
			case .SqFt:
				if minSqFts[row] == 0
				{
					return "Any"
				} else
				{
					return "\(minSqFts[row])"
				}
			
			case .Lot:
				if minLot[row] <= 20000
				{
					if minLot[row] == 0
					{
						return "Any"
					} else
					{
						return "\(decimalFormatter.stringFromNumber(minLot[row])!) Sq.Ft."
					}
				} else
				{
					return acres[minLot[row]]
				}
			
			case .Year:
				if minYear[row] == 0
				{
					return "Any"
				} else
				{
					return "\(minYear[row])"
				}
			
			case .ListedWithin:
				return HLSearch.ListingAge.allValues[row].rawValue
		}
	}
	
	func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
	{
		selectedPickerRowForState[pickerState] = row
		
		switch pickerState
		{
			case .SaleRent:
				search.listingType = HLSearch.ListingType.allValues[row]
				listingTypeButton.setTitle(HLSearch.ListingType.allValues[row].rawValue, forState: .Normal)
			
			case .PropertyType:
				search.propertyType = HLProperty.PropertyType.allValues[row]
				propertyTypeButton.setTitle(HLProperty.PropertyType.allValues[row].rawValue, forState: .Normal)
			
			case .SqFt:
				search.minSqFt = minSqFts[row]
				if minSqFts[row] == 0
				{
					minSqFtButton.setTitle("Any", forState: .Normal)
				} else
				{
					minSqFtButton.setTitle("\(minSqFts[row])", forState: .Normal)
				}
			
			case .Lot:
				search.minLot = minLot[row]
				if minLot[row] <= 20000 // For more than 20000 sqft show in acres using a lookup table
				{
					if minLot[row] == 0
					{
						minLotButton.setTitle("Any", forState: .Normal)
					} else
					{
						minLotButton.setTitle("\(decimalFormatter.stringFromNumber(minLot[row])!) Sq.Ft.", forState: .Normal)
					}
				} else
				{
					minLotButton.setTitle(acres[minLot[row]], forState: .Normal)
				}
			
			case .Year:
				search.minYear = minYear[row]
				if minYear[row] == 0
				{
					minYearButton.setTitle("Any", forState: .Normal)
				} else
				{
					minYearButton.setTitle("\(minYear[row])", forState: .Normal)
				}
			
			case .ListedWithin:
				search.listingAge = HLSearch.ListingAge.allValues[row]
				listedWithinButton.setTitle(HLSearch.ListingAge.allValues[row].rawValue, forState: .Normal)
		}
	}
	
	// MARK: - TTRangeSliderDelegate
	func rangeSlider(sender: TTRangeSlider!, didChangeSelectedMinimumValue selectedMinimum: Float, andMaximumValue selectedMaximum: Float)
	{
		if Int(priceSlider.selectedMinimum) > 0
		{
			sliderLowLabel.text = "$" + decimalFormatter.stringFromNumber(Int(priceSlider.selectedMinimum))!
			search.minPrice = Int(priceSlider.selectedMinimum)
		} else
		{
			sliderLowLabel.text = "Price"
			search.minPrice = nil
		}
		
		if selectedMinimum != oldPriceSelectedMin
		{
			if selectedMinimum > 1000001
			{
				sender.step = 100000
			} else
			{
				sender.step = 20000
			}
			oldPriceSelectedMin = selectedMinimum
		} else if selectedMaximum != oldPriceSelectedMax
		{
			if selectedMaximum > 1000001
			{
				sender.step = 100000
			} else
			{
				sender.step = 20000
			}
			
			oldPriceSelectedMax = selectedMaximum
		}
		
		if Int(priceSlider.selectedMaximum) < 5000000
		{
			sliderHighLabel.text = "$" + decimalFormatter.stringFromNumber(Int(priceSlider.selectedMaximum))!
			search.maxPrice = Int(priceSlider.selectedMaximum)
		} else
		{
			sliderHighLabel.text = "Any Price"
			search.maxPrice = nil	
		}
	}
	
	// MARK: - UISearchBarDelegate
	func searchBarSearchButtonClicked(searchBar: UISearchBar)
	{
		searchAutocompleteTable.hidden = true
		if let address = addressSearch.text
		{
			if let zip = Int(address) where zip > 9999 && zip < 100000
			{
				let address = HLSearch.Address()
				address.zip = zip
				self.search.address = address
				self.search.zips = nil
			} else
			{
				LMGeocoder.sharedInstance().geocodeAddressString(address, service: .AppleService) { (results, error) -> Void in
					guard error == nil
						else
					{
						log.error(error!.localizedDescription)
						return
					}
		
					guard let results = results as? [LMAddress], result = results.first
						else
					{
						log.error("Could not get results from geocoding")
						return
					}
					
					let address = HLSearch.Address()
					
					if let zipString = result.postalCode, zip = Int(zipString)
					{
						address.zip = zip
					}
					
					address.state = result.administrativeArea
					address.county = result.subLocality
					address.city = result.locality
					
					self.search.zips = nil
					
					self.search.address = address
				}
			}
			
			self.addressSearch.resignFirstResponder()
			UIView.animateWithDuration(Constants.Values.animationDurationShort) {
				self.searchAutocompleteTable.hidden = true
			}
		}
	}
	
	func searchBar(searchBar: UISearchBar, textDidChange searchText: String)
	{
		
		HNKGooglePlacesAutocompleteQuery.sharedQuery().fetchPlacesForSearchQuery(searchBar.text!) { (places, error) -> Void in
			if let error = error
			{
				log.error("Goole Places Autocomplete error: \(error.localizedDescription)")
			} else if let places = places as? [HNKGooglePlacesAutocompletePlace]
			{
				let me = HNKGooglePlacesAutocompletePlace()
				me.name = self.addressSearch.text // Remove readonly for name from pod source
				
				self.locationAutocompleteSuggestions = [me] + places
				self.searchAutocompleteTable.reloadData()
				
				UIView.animateWithDuration(Constants.Values.animationDurationShort) {
					self.searchAutocompleteTable.hidden = false
				}
			}
		}
	}
	
	// MARK: - UITableViewDataSource
	
	// Used only for UISearchBar
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int
	{
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		if locationAutocompleteSuggestions.count == 0
		{
			return 0
		} else
		{
			return locationAutocompleteSuggestions.count + 1 // If there are results - add attribution to google
		}
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
	{
		let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIds.searchSuggestionTableCell, forIndexPath: indexPath)
		
		if indexPath.row < locationAutocompleteSuggestions.count
		{
			let place = locationAutocompleteSuggestions[indexPath.row]
			cell.textLabel?.font = UIFont.systemFontOfSize(16)
			cell.textLabel?.text = place.name
		} else
		{
			cell.textLabel?.font = UIFont.systemFontOfSize(10)
			cell.textLabel?.text = "Powered by Google"
		}
		
		return cell
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
	{
		let place = locationAutocompleteSuggestions[indexPath.row]
		
		LMGeocoder.sharedInstance().geocodeAddressString(place.name, service: .AppleService) { (results, error) -> Void in
			guard error == nil
				else
			{
				log.error(error!.localizedDescription)
				return
			}
			
			guard let results = results as? [LMAddress], result = results.first
				else
			{
				log.error("Could not get results from geocoding")
				return
			}
			
			
			let address = HLSearch.Address()
			
			if let zipString = result.postalCode, zip = Int(zipString)
			{
				address.zip = zip
			}
			
			address.state = result.administrativeArea
			address.county = result.subLocality
			address.city = result.locality
			
			self.search.address = address
			
			self.addressSearch.text = place.name

			UIView.animateWithDuration(Constants.Values.animationDurationShort) {
				self.searchAutocompleteTable.hidden = true
			}
			self.addressSearch.resignFirstResponder()
		}
		
		return
	}
	
}
