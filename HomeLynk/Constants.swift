//
//  Constants.swift
//  HomeLynk
//
//  Created by William Santiago on 1/12/16.
//  Copyright © 2016 William Santiago. All rights reserved.
//

import UIKit

struct Constants
{
	struct URLStrings
	{
		static let homeLynkServer                = "http://localhost:3000"
//		static let homeLynkServer                = "https://arcane-brook-86709.herokuapp.com"
		
        static let nyRetsServer                  = "http://www.nysrets.com:6160/rets"
	}
	

	struct SegueIds
	{
        static let bustaToPropertiesView         = "bustaToPropertiesView"
        static let searchToListResults           = "searchToListResults"
        static let listPropertiesToPropertyView  = "listPropertiesToPropertyView"
        static let listPropertiesToMap           = "listPropertiesToMap"
        static let contactPropertyAgent          = "contactPropertyAgent"
	}

	struct StoryboardIds
	{
        static let LoginNavigationController     = "LoginNavigationController"
        static let MainNavigationController      = "MainNavigationController"
        static let MapViewController             = "MapViewController"
        static let LeftMenuViewController        = "LeftMenuViewController"
        static let ListPropertiesViewController  = "ListPropertiesViewController"
        static let BustaTabBarController         = "BustaTabBarController"
        static let SavedSearchesViewController   = "SavedSearchesViewController"
        static let AccountSettingsViewController = "AccountSettingsViewController"
		static let ContactAgentViewController	 = "ContactAgentViewController"
	}

	struct CellIds
	{
        static let propertyImageCell             = "propertyImageCell"
        static let savedSearchCell               = "savedSearchCell"
        static let propertyImageLoadingCell      = "propertyImageLoadingCell"
		
		static let propertyResultTableCell		 = "propertyResultTableCell"
		static let propertySearchTableCell		 = "propertySearchTableCell"
		
		static let searchSuggestionTableCell	 = "searchSuggestionTableCell"
	}

	struct NotificationIds
	{
        static let PropertyLoadedImages          = "PropertyLoadedImages"
	}

	struct Keys
	{
        static let kDefaultsUserAnonymousId      = "defaults.user.anonymousId"
		static let kDefaultsHiddenProperties	 = "defaults.user.hiddenProperties"
		static let kDefaultsSavedProperties		 = "defaults.user.savedProperties"
		
		static let kDefaultsBlockBustaTipShown	 = "defaults.user.blockBustaTipShown"

        static let kMultipartDataHeaders         = "headers"
        static let kMultipartDataBody            = "body"

        static let kHTTPHeaderContentType        = "Content-Type"
        static let kHTTPHeaderContentID          = "Content-ID"
        static let kHTTPHeaderObjectID           = "Object-ID"

        static let kMIMETypeImage                = "image/jpeg"
	}

	struct Values
	{
        static let animationDurationShort        = 0.25
        static let animationDurationMedium       = 0.5
        static let animationDurationLong         = 1

        static let daysToNSTimeInterval: Double  = 60*60*24
		
		static let propertyListPerLoad = 6
		static let propertyResultsPerRequest = 200
		
		static let PlatformString	= "ios"
		
		static let searchMinPrice = 0
		static let searchMaxPrice = 10000000
	}

	struct Colors
	{
        static let LightBlue                     = UIColor(red: 31/255, green: 193/255, blue: 242/255, alpha: 1)
        static let PlaceholderGray               = UIColor(red: 199/255, green: 199/255, blue: 206/255, alpha: 1)
	}

	struct Strings
	{
        static let areadUnits                    = "sq ft"
	}
}
