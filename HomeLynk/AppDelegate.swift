//
//  AppDelegate.swift
//  HomeLynk
//
//  Created by William Santiago on 1/11/16.
//  Copyright © 2016 William Santiago. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import ViewDeck
import XCGLogger


import HNKGooglePlacesAutocomplete
import LMGeocoder

let log = XCGLogger.defaultInstance()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{

	var window: UIWindow?

	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
	{
		// Push
		let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
		application.registerUserNotificationSettings(settings)
		UIApplication.sharedApplication().registerForRemoteNotifications()
		
		// Appearance
		UINavigationBar.appearance().barTintColor = UIColor.whiteColor()
		UINavigationBar.appearance().translucent = false
		UINavigationBar.appearance().tintColor = Constants.Colors.LightBlue
		UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : Constants.Colors.LightBlue]
		
		UINavigationBar.appearance().backIndicatorImage = UIImage(named: "blue_settings_icon")
		UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage(named: "blue_settings_icon")
		
		UITabBar.appearance().tintColor = UIColor.whiteColor()
		
		//Does not take possible device rotation in account, as currently, the app is iPhone Portrait only
		UITabBar.appearance().backgroundImage =  UIImage.imageWithColor(UIColor.whiteColor(),
			size: CGSizeMake(UIScreen.mainScreen().bounds.width, 49)).resizableImageWithCapInsets(UIEdgeInsetsMake(0, 0, 0, 0))
		
		UITabBar.appearance().selectionIndicatorImage = UIImage.imageWithColor(Constants.Colors.LightBlue,
			size: CGSizeMake(UIScreen.mainScreen().bounds.width / 2, 49))
		
		UITabBarItem.appearance().titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -10)
	
		UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : Constants.Colors.LightBlue,
			NSFontAttributeName : UIFont.systemFontOfSize(17)],
			forState: .Normal)
		
		UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.whiteColor(),
			NSFontAttributeName : UIFont.systemFontOfSize(17)],
			forState: .Selected)
		
		let fileManager = NSFileManager.defaultManager()
		let cachesURL = fileManager.URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)[0]
		let imagesCacheURL = cachesURL.URLByAppendingPathComponent("nyrets/")
		Settings.General.imagesCacheFolder = imagesCacheURL
		
		if !fileManager.fileExistsAtPath(imagesCacheURL.path!)
		{
			try! fileManager.createDirectoryAtURL(Settings.General.imagesCacheFolder,
					  withIntermediateDirectories: true,
									   attributes: nil) //TODO: Unlikely, but maybe error handle?
		}
		
		log.setup(.Verbose, showLogIdentifier: false, showFunctionName: true, showThreadName: true, showLogLevel: true, showFileNames: true, showLineNumbers: true, showDate: true, writeToFile: nil, fileLogLevel: nil)
		
		Settings.General.imagesCacheFolder = imagesCacheURL
		
		IQKeyboardManager.sharedManager().enable = true
		
		HNKGooglePlacesAutocompleteQuery.setupSharedQueryWithAPIKey(SecureConstants.Accounts.Google.placesAPIKey)
		
		if Settings.User.anonymousId == nil
		{
			Settings.User.anonymousId = NSUUID().UUIDString
		}
		
		LMGeocoder.sharedInstance().googleAPIKey = SecureConstants.Accounts.Google.placesAPIKey
		
		return true
	}

	func applicationWillResignActive(application: UIApplication)
	{
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(application: UIApplication)
	{
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(application: UIApplication)
	{
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(application: UIApplication)
	{
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(application: UIApplication)
	{
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}

	
	// MARK: - Push Notifications
	
	func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void)
	{
		
	}
	
	func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData)
	{
		let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
		var tokenString = ""
		for i in 0..<deviceToken.length {
			tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
		}
		
		Settings.Device.pushToken = tokenString
		
		log.info("Device token \(Settings.Device.pushToken)")
	}
}

