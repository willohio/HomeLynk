//
//  MapViewController.swift
//  HomeLynk
//
//  Created by William Santiago on 1/12/16.
//  Copyright © 2016 William Santiago. All rights reserved.
//

import UIKit
import MapKit

import Alamofire

import ViewDeck
import LMGeocoder

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, IIViewDeckControllerDelegate
{
	// MARK: - Properties
	
	var properties: [HLProperty]?
	{
		didSet
		{
			propertyForPlacemark.removeAll()
			
			//Can be nil when setting the property after manually instantiating from Storyboard
			//viewDidLoad has not been called yet and outlets are not set
			if let mapView = mapView
			{
				mapView.removeAnnotations(mapView.annotations)
				
				if let properties = properties
				{
					requestPropertiesLocationAndDisplay(properties)
				}
			}
			
			if let resultsLabel = resultsLabel
			{
				if let properties = properties
				{
					resultsLabel.hidden = false
					resultsLabel.text = "\(properties.count) Results"
				} else
				{
					resultsLabel.hidden = true
				}
			}
		}
	}
	
	var isNotHomeScreen = false
	
	// MARK: Private
	private let locationManager = CLLocationManager()
	private let propertyViewPressedRecognizer = UITapGestureRecognizer()
	
	private var propertyForPlacemark = [MKPlacemark : HLProperty]()
	
	private var visibleZips: [Int]?
	private var visibleProperties: [HLProperty]?
	{
		didSet
		{
			propertyForPlacemark.removeAll()
			
			//Can be nil when setting the property after manually instantiating from Storyboard
			//viewDidLoad has not been called yet and outlets are not set
			if let mapView = mapView
			{
				mapView.removeAnnotations(mapView.annotations)
				
				if let visibleProperties = visibleProperties
				{
					requestPropertiesLocationAndDisplay(visibleProperties)
				}
			}
			
			if let resultsLabel = resultsLabel
			{
				if let properties = properties
				{
					resultsLabel.hidden = false
					resultsLabel.text = "\(properties.count) Results"
				} else
				{
					resultsLabel.hidden = true
				}
			}
		}
	}
	
	private var visibleZipsRequest: Alamofire.Request?
	private var visiblePropertiesRequest: Alamofire.Request?
	
	
	private var lastRegionChanged: NSDate? // Used to avoid updating the map too often when scrolling
	private let minIntervalForUpdate = 1.0
	private var placingProperties = false // Flag used while placing properties, to disable the visible zip update on map region change
	
	private let segueToSearch = "mapToSearch"
	private let segueToList = "mapToListResults"
	private let segueToProperty = "mapToPropertyView"
	
	
	// MARK: Outlets
	
	@IBOutlet var resultsLabel: UILabel!
	@IBOutlet var mapView: MKMapView!
	@IBOutlet var propertyView: PropertyView!
	
	@IBOutlet var showPropertyViewConstraint: NSLayoutConstraint!
	@IBOutlet var hidePropertyViewConstraint: NSLayoutConstraint!
	
	// MARK: - Actions
	
	@IBAction func menuPressed(sender: UIBarButtonItem)
	{
		self.navigationController!.viewDeckController.toggleLeftView()
		if navigationController!.viewDeckController.isSideOpen(IIViewDeckSide.LeftSide)
		{
			self.navigationController!.viewDeckController.centerhiddenInteractivity = .NotUserInteractiveWithTapToClose
			navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu_close"), style: .Plain, target: self, action: "menuPressed:")
		} else
		{
			self.navigationController!.viewDeckController.centerhiddenInteractivity = .UserInteractive
			navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu_open"), style: .Plain, target: self, action: "menuPressed:")
		}
	}
	
	@IBAction func showUserLocation(sender: UIButton)
	{
		if let userLocation = mapView.userLocation.location
		{
			let userRegion = MKCoordinateRegionMake(userLocation.coordinate, MKCoordinateSpanMake(0.2, 0.2))

			mapView.setRegion(userRegion, animated: true)
		}
	}
	
	
	@IBAction func layersPressed(sender: UIButton)
	{
		let alert = UIAlertController(title: "Map Mode", message: nil, preferredStyle: .ActionSheet)
		
		let standard = UIAlertAction(title: "Standard", style: .Default) { (action) -> Void in
			self.mapView.mapType = .Standard
		}
		
		let satellite = UIAlertAction(title: "Satellite", style: .Default) { (action) -> Void in
			self.mapView.mapType = .Satellite
		}
		
		let hybrid = UIAlertAction(title: "Hybrid", style: .Default) { (action) -> Void in
			self.mapView.mapType = .Hybrid
		}
		
		let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
		
		alert.addAction(standard)
		alert.addAction(satellite)
		alert.addAction(hybrid)
		alert.addAction(cancel)
		
		self.presentViewController(alert, animated: true, completion: nil)
	}
	
	@IBAction func mapDrawPressed(sender: UIButton)
	{
	}
	
	
	@IBAction func returnToMapWithProperties(segue: UIStoryboardSegue)
	{
		if let properties = properties
		{
			requestPropertiesLocationAndDisplay(properties)
		}
	}
	
	
	// MARK: - Lifecycle
	
    override func viewDidLoad()
	{
        super.viewDidLoad()
		
		self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil) //Removes the title from the back button on the next screen
		self.navigationController?.viewDeckController.delegate = self
		
		locationManager.delegate = self
		mapView.delegate = self
		
		if true//CLLocationManager.authorizationStatus() == .NotDetermined
		{
			locationManager.requestWhenInUseAuthorization()
		}
		
		if let userLocation = mapView.userLocation.location
		{
			mapView.setCenterCoordinate(userLocation.coordinate, animated: true)
		}
		
		propertyViewPressedRecognizer.addTarget(self, action: "propertyPressed")
		propertyView.addGestureRecognizer(propertyViewPressedRecognizer)
		
		//Properties are set, but no annotations yet - MapView was nil when .properties was set
		if let properties = properties
			where mapView.annotations.count == 0
		{
			resultsLabel.hidden = false
			requestPropertiesLocationAndDisplay(properties) { () -> () in
				self.fitAllAnotations()
			}
			resultsLabel.text = "\(properties.count) Results"
		}
    }

	override func viewWillAppear(animated: Bool)
	{
		super.viewWillAppear(animated)
		
		navigationController?.viewDeckController.panningMode = IIViewDeckPanningMode.FullViewPanning
		
		self.navigationController?.setNavigationBarHidden(false, animated: true)
		
		if !isNotHomeScreen
		{
			if navigationController!.viewDeckController.isSideOpen(IIViewDeckSide.LeftSide)
			{
				navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu_close"), style: .Plain, target: self, action: "menuPressed:")
			} else
			{
				navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu_open"), style: .Plain, target: self, action: "menuPressed:")
			}
		}
	}
	
	override func viewWillDisappear(animated: Bool)
	{
		super.viewWillDisappear(animated)
		
		navigationController?.viewDeckController.panningMode = IIViewDeckPanningMode.NoPanning
		
		visibleZipsRequest?.cancel()
		visiblePropertiesRequest?.cancel()
	}
	
	override func viewDidLayoutSubviews()
	{
		super.viewDidLayoutSubviews()
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
	{
		if let segueId = segue.identifier
		{
			if let destVC = segue.destinationViewController as? PropertyViewController
				where segueId == segueToProperty
			{
				destVC.property = propertyView.property
			} else if let destVC = segue.destinationViewController as? ListPropertiesViewController, properties = properties
				where segueId == segueToList
			{
				destVC.propertiesWithoutPreview = properties
			} else if let destVC = segue.destinationViewController as? SearchViewController, visibleZips = visibleZips
				where segueId == segueToSearch
			{
				destVC.zipsToSearch = visibleZips
			}
		}
	}
	
	// MARK: - CLLocationManagerDelegate
	
	func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus)
	{
		switch status
		{
			case .AuthorizedWhenInUse, .AuthorizedAlways:
				mapView.showsUserLocation = true
			default:
				log.info("Location not allowed by user")
		}
	}
	
	
	// MARK: - MKMapViewDelegate
	
	func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool)
	{
		guard placingProperties == false // Do not update when region was changed due to placing new properties
			else
		{
			return
		}
		
		guard properties == nil // Only update zips if not showing properties
			else
		{
			return
		}
		
		guard mapView.region.span.latitudeDelta < 0.5 // Don't try to fetch zip codes for too large areas
			else
		{
			return
		}
		
		if lastRegionChanged == nil
		{
			lastRegionChanged = NSDate()
		} else
		{
			if NSDate().timeIntervalSinceDate(lastRegionChanged!) < minIntervalForUpdate
			{
				return
			}
		}
		
		let upperLeftCoord = mapView.convertPoint(CGPoint(x: 0, y: 0), toCoordinateFromView: mapView)
		let lowerRightCoord = mapView.convertPoint(CGPoint(x: mapView.frame.size.width, y: mapView.frame.size.height), toCoordinateFromView: mapView)
		
		let upperLeft = CGPoint(x: upperLeftCoord.latitude, y: upperLeftCoord.longitude)
		let lowerRight = CGPoint(x: lowerRightCoord.latitude, y: lowerRightCoord.longitude)
		
		visibleZipsRequest?.cancel()
		visibleZipsRequest = HLZipCodeRequest.findZipsInGeoRect(
			upperLeft: upperLeft,
			lowerRight: lowerRight,
			successHandler: { (zipCodes) -> () in
				self.visibleZipsRequest = nil
				self.visibleZips = zipCodes
				
				if zipCodes != nil
				{
					let search = HLSearch()
					search.zips = zipCodes
					
					self.visiblePropertiesRequest?.cancel()
					self.visiblePropertiesRequest = NYRetsProvider.getPropertiesFromHLSearch(search,
						successHandler: { (properties) -> () in
							self.visiblePropertiesRequest = nil
							
							let currentUpperLeft = mapView.convertPoint(CGPoint(x: 0, y: 0), toCoordinateFromView: mapView)
							let currentLowerRight = mapView.convertPoint(CGPoint(x: mapView.frame.size.width, y: mapView.frame.size.height), toCoordinateFromView: mapView)
							
							// If the map was panned since the request has been made, ignore this properties
							if upperLeftCoord.latitude != currentUpperLeft.latitude
								|| upperLeftCoord.longitude != currentUpperLeft.longitude
							{
								return
							}
							
							// Filter out properties outside of the visible screen
							var locationlessProperties = [HLProperty]()
							let properties = properties.filter { (property) -> Bool in
								if property.location == nil
								{
									locationlessProperties.append(property)
									return false
								} else
								{
									let location = property.location!
									if true  || (location.latitude > min(currentUpperLeft.latitude, currentLowerRight.latitude)
										&& location.latitude < max(currentUpperLeft.latitude, currentLowerRight.latitude)
										&& location.longitude > min(currentUpperLeft.longitude, currentLowerRight.longitude)
										&& location.longitude < max(currentUpperLeft.longitude, currentLowerRight.longitude))
									{
										return true
									} else
									{
										return false
									}
								}
								
							}
							
							// Don't try to geocode too many properties or the geocoding server will refuse to service us
							if locationlessProperties.count > 20
							{
								locationlessProperties = Array(locationlessProperties[0..<20])
							}
							
							self.visibleProperties = properties + locationlessProperties // TODO: currently requestPropertiesLocationAndDisplay will filter again. Refactor
						},
						failureHandler: { (requestError) -> () in
							self.visiblePropertiesRequest = nil
					})
				}
			},
			failureHandler: { (error) -> () in
				self.visibleZipsRequest = nil
				self.visibleZips = nil
				log.error("Could not get zip codes for currently displayed location")
		})
		
		lastRegionChanged = NSDate()
	}
	
	func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?
	{
		if annotation is MKUserLocation
		{
			return nil
		}
		
		let defaultPinId = "propertyPin"
		
		var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(defaultPinId)
		if annotationView == nil
		{
			annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: defaultPinId)
		}
		
		annotationView!.canShowCallout = false
		annotationView!.image = UIImage(named: "point")
		
		
		return annotationView
	}
	
	func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView)
	{
		guard let placemark = view.annotation as? MKPlacemark
			else
		{
			log.error("No placemark found")
			return
		}
		
		guard let property = propertyForPlacemark[placemark]
			else
		{
			log.error("No property found")
			return
		}
		
		propertyView.setupForProperty(property)
		
		hidePropertyViewConstraint.active = false
		showPropertyViewConstraint.active = true
		
		UIView.animateWithDuration(Constants.Values.animationDurationShort) { () -> Void in
			self.view.layoutIfNeeded()
		}
	}
	
	func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView)
	{
		showPropertyViewConstraint.active = false
		hidePropertyViewConstraint.active = true
		
		UIView.animateWithDuration(Constants.Values.animationDurationShort) { () -> Void in
			self.view.layoutIfNeeded()
		}
	}
	
	
	// MARK: - IIViewDeckControllerDelegate
	
	func viewDeckController(viewDeckController: IIViewDeckController!, willOpenViewSide viewDeckSide: IIViewDeckSide, animated: Bool)
	{
		navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu_close"), style: .Plain, target: self, action: "menuPressed:")
	}
	
	func viewDeckController(viewDeckController: IIViewDeckController!, willCloseViewSide viewDeckSide: IIViewDeckSide, animated: Bool)
	{
		navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu_open"), style: .Plain, target: self, action: "menuPressed:")
	}
	
	// MARK: - Other
	
	func propertyPressed()
	{
		self.performSegueWithIdentifier(segueToProperty, sender: nil)
	}
	
	// MARK: - Private
	
	// TODO: Handle only properties without address
	private func requestPropertiesLocationAndDisplay(properties: [HLProperty], completion: (() -> ())? = nil) //, skipOutsideScreen: Bool)
	{
		placingProperties = true
		
		let locationlessProperties = properties.filter { $0.location == nil }
		let properties = properties.filter { $0.location != nil }
		
		for property in properties
		{
			let mkPlacemark = MKPlacemark(coordinate: property.location!, addressDictionary: nil)
			self.propertyForPlacemark[mkPlacemark] = property
			self.mapView.addAnnotation(mkPlacemark)
		}
		
		let geocodeGroup = dispatch_group_create() // Use a dispatch group to schedule a call to fitAllAnotations once all handlers have returned
		dispatch_group_enter(geocodeGroup) // Gurantee at least one entry & leave to fire the dispatch notification at least once
		
		for property in locationlessProperties
		{
			if let address = property.address
			{
				dispatch_group_enter(geocodeGroup)
				LMGeocoder().geocodeAddressString(address, service: .GoogleService) { (results, error) -> Void in
					defer {
						dispatch_group_leave(geocodeGroup)
					}
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
					
					// Skip results outside of screen
					
					let currentUpperLeft = self.mapView.convertPoint(CGPoint(x: 0, y: 0), toCoordinateFromView: self.mapView)
					let currentLowerRight = self.mapView.convertPoint(CGPoint(x: self.mapView.frame.size.width, y: self.mapView.frame.size.height), toCoordinateFromView: self.mapView)

					if true || (result.coordinate.latitude > min(currentUpperLeft.latitude, currentLowerRight.latitude)
						&& result.coordinate.latitude < max(currentUpperLeft.latitude, currentLowerRight.latitude)
						&& result.coordinate.longitude > min(currentUpperLeft.longitude, currentLowerRight.longitude)
						&& result.coordinate.longitude < max(currentUpperLeft.longitude, currentLowerRight.longitude))
					{
						return
					}

					
					let mkPlacemark = MKPlacemark(coordinate: result.coordinate, addressDictionary: nil)
					self.propertyForPlacemark[mkPlacemark] = property
					self.mapView.addAnnotation(mkPlacemark)
				}
			}
		}
		
		dispatch_group_leave(geocodeGroup) // Gurantee at least one entry & leave to fire the dispatch notification at least once
		dispatch_group_notify(geocodeGroup, dispatch_get_main_queue()) {
			self.placingProperties = false
			completion?()
		}
	}
	
	private func fitAllAnotations()
	{
		guard mapView.annotations.count > 0
			else
		{
			return
		}
		
		var topLeft = CLLocationCoordinate2D(latitude: -90, longitude: 180)
		var bottomRight = CLLocationCoordinate2D(latitude: 90, longitude: -180)
		
		for annotation in mapView.annotations
		{
			topLeft.latitude = fmax(topLeft.latitude, annotation.coordinate.latitude)
			topLeft.longitude = fmin(topLeft.longitude, annotation.coordinate.longitude)
			
			bottomRight.latitude = fmin(bottomRight.latitude, annotation.coordinate.latitude)
			bottomRight.longitude = fmax(bottomRight.longitude, annotation.coordinate.longitude)
		}
		
		var region = MKCoordinateRegion(
			center: CLLocationCoordinate2D(
				latitude: topLeft.latitude - (topLeft.latitude - bottomRight.latitude) * 0.5,
				longitude: topLeft.longitude + (bottomRight.longitude - topLeft.longitude) * 0.5),
			span: MKCoordinateSpan(
				latitudeDelta: fabs(topLeft.latitude - bottomRight.latitude) * 1.2, //Add some padding to the screen
				longitudeDelta: fabs(bottomRight.longitude - topLeft.longitude) * 1.2))
		region = mapView.regionThatFits(region)
		
		mapView.setRegion(region, animated: true)
	}
	
	private func displayPropertyDetails(property: HLProperty)
	{
		propertyView.setupForProperty(property)
	}
}
