//
//  LeftMenuViewController.swift
//  HomeLynk
//
//  Created by Ivan Dilchovski on 1/14/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import UIKit

import ViewDeck
import MessageUI

class LeftMenuViewController: UIViewController, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate
{
	
	@IBOutlet weak var bustaButton: UIButton!
	@IBOutlet var buttons: [UIButton]!
	
	@IBOutlet var feedbackButton: UIButton!
	@IBOutlet var logOutButton: UIButton!
	
	@IBOutlet var savedHomesButton: UIButton!
	
	@IBAction func blockBustaPressed(sender: UIButton)
	{
		if let navController = self.viewDeckController?.centerController as? UINavigationController
		{
			let savedSearches = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(Constants.StoryboardIds.SavedSearchesViewController) as! SavedSearchesViewController
			
			savedSearches.isBlockBusta = true
			navController.pushViewController(savedSearches, animated: true)
			
			HLSearchRequest.getSavedSearchesForUser(
				successHandler: { (searches) -> () in
					savedSearches.searches = searches.filter { $0.isBlockBusta }
				}, failureHandler: { (error) -> () in
					savedSearches.searches = [HLSearch]() //Hides the loading indicator. Ugly
			})
		}
		
		self.viewDeckController.toggleLeftView()
	}
	
	@IBAction func savedHomesPressed(sender: UIButton)
	{
		if let navController = self.viewDeckController?.centerController as? UINavigationController
		{
			let savedHomes = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(Constants.StoryboardIds.ListPropertiesViewController) as! ListPropertiesViewController
			savedHomes.listSourceType = .SavedHomes
			navController.pushViewController(savedHomes, animated: true)
			
			HLUsersSavedPropertiesRequest.getSavedPropertiesForUser(
				successHandler: { (propertyMlsids) -> () in
					if propertyMlsids.count > 0
					{
						let search = HLSearch()
						search.propertyIds = propertyMlsids
						NYRetsProvider.getPropertiesFromHLSearch(search,
							successHandler: { (properties) -> () in
								savedHomes.propertiesWithoutPreview = properties
							},
							failureHandler: { (requestError) -> () in
								savedHomes.presentViewController(requestError.getGenericAlert(), animated: true, completion: nil)
								savedHomes.propertiesWithPreview = [HLProperty]() // FIXME: Ugly - hides activityIndicator
						})
					}
				}, failureHandler: { (requestError) -> () in
					self.presentViewController(requestError.getGenericAlert(), animated: true, completion: nil)
			})
		}
		
		self.viewDeckController.toggleLeftView()
	}
	
	@IBAction func savedSearches(sender: UIButton)
	{
		if let navController = self.viewDeckController?.centerController as? UINavigationController
		{
			let savedSearches = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(Constants.StoryboardIds.SavedSearchesViewController) as! SavedSearchesViewController
			
			navController.pushViewController(savedSearches, animated: true)
			
			HLSearchRequest.getSavedSearchesForUser(
				successHandler: { (searches) -> () in
					savedSearches.searches = searches.filter { !$0.isBlockBusta }
				}, failureHandler: { (error) -> () in
					savedSearches.searches = [HLSearch]() //Hides the loading indicator. Ugly
			})
		}
		
		self.viewDeckController.toggleLeftView()
	}
	
	@IBAction func settingsPressed(sender: UIButton)
	{
		if let navController = self.viewDeckController?.centerController as? UINavigationController
		{
			let savedHomes = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(Constants.StoryboardIds.AccountSettingsViewController)
			navController.pushViewController(savedHomes, animated: true)
		}
		
		self.viewDeckController.toggleLeftView()
	}
	
	@IBAction func feedbackPressed(sender: UIButton)
	{
		if MFMailComposeViewController.canSendMail()
		{
			let mailComposer = MFMailComposeViewController()
			mailComposer.delegate = self
			mailComposer.setToRecipients(["feedback@homelynk.com"])
			mailComposer.setSubject("Feedback")
			
			self.presentViewController(mailComposer, animated: true, completion: nil)
		} else
		{
			let alertController = UIAlertController(title: "You have not email accounts setup", message: nil, preferredStyle: .Alert)
			let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
			alertController.addAction(okAction)
			
			self.presentViewController(alertController, animated: true, completion: nil)
		}
	}
	
	@IBAction func logoutPressed(sender: UIButton)
	{
		LoginHelper.logout()
		
		let loginNavController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(Constants.StoryboardIds.LoginNavigationController)
		let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
		
		self.viewDeckController.toggleLeftView()
		
		delegate.window?.rootViewController = loginNavController
	}
	
	
    override func viewDidLoad()
	{
        super.viewDidLoad()
		
		for button in buttons
		{
			button.setImageSpacing(8)
			button.setTitleColor(UIColor.lightTextColor(), forState: UIControlState.Disabled)
			
			if HLUser.currentUser == nil
			{
				
				if button != feedbackButton && button != logOutButton && button != savedHomesButton
				{
					button.enabled = false
				}
			}
		}
		
		bustaButton.setTitleColor(UIColor.lightTextColor(), forState: UIControlState.Disabled)
		if HLUser.currentUser == nil
		{
			bustaButton.enabled = false
		}
    }

    override func didReceiveMemoryWarning()
	{
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	// MARK: - MFMailComposeViewControllerDelegate
	func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?)
	{
		self.dismissViewControllerAnimated(true, completion: nil)
	}
}
