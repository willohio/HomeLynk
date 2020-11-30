//
//  ViewController.swift
//  HomeLynk
//
//  Created by William Santiago on 1/11/16.
//  Copyright © 2016 William Santiago. All rights reserved.
//

import UIKit

import SMPageControl
import ViewDeck

class LoginViewController: UIViewController, UIScrollViewDelegate
{

	@IBOutlet var carouselScrollView: UIScrollView!
	@IBOutlet var carouselPageControll: SMPageControl!
	@IBOutlet var imagesStackView: UIStackView!
	
	@IBOutlet var activityIndicator: UIActivityIndicatorView!
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		attemptLogin()
		
		self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil) //Removes the title from the back button on the next screen
		carouselScrollView.delegate = self
		
		carouselPageControll.numberOfPages = 4
		carouselPageControll.pageIndicatorImage = UIImage(named: "slider_circle")
		carouselPageControll.currentPageIndicatorImage = UIImage(named: "slider_circle_active")
		carouselPageControll.sizeToFit()
		
		
	}
	
	override func viewWillAppear(animated: Bool)
	{
		super.viewWillAppear(animated)
		self.navigationController?.setNavigationBarHidden(true, animated: true)
	}

	override func didReceiveMemoryWarning()
	{
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func scrollViewDidScroll(scrollView: UIScrollView)
	{
		scrollView.contentOffset.y = 0
		
		let pageWidth = scrollView.frame.size.width;
		let page = Int(floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1)
		carouselPageControll.currentPage = page;
	}
	
	
	// MARK: - Private
	
	func attemptLogin()
	{
		if LoginHelper.getEmailAndTokenFromKeychain() != nil
		{
			activityIndicator.startAnimating()
			
			LoginHelper.loginWithKeychain(
				successHandler: { (user) -> () in
					NYRetsLoginRequest.login(
						username: SecureConstants.Accounts.NYRets.username,
						password: SecureConstants.Accounts.NYRets.password,
						successHandler: nil,
						failureHandler: { (error) -> () in
							
					})
					
					HLUser.currentUser = user
					
					let mainNavController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(Constants.StoryboardIds.MainNavigationController)
					let leftMenuController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(Constants.StoryboardIds.LeftMenuViewController)
					let deckController = IIViewDeckController(centerViewController: mainNavController, leftViewController: leftMenuController)
					
					let delegate = UIApplication.sharedApplication().delegate as? AppDelegate
					delegate?.window?.rootViewController = deckController
					
					self.activityIndicator.stopAnimating()
				},
				failureHandler: { (requestError) -> () in
					self.activityIndicator.stopAnimating()
					
					if case .StatusCode(let statusCode, _) = requestError where statusCode == 401
					{
						log.info("Stored credentials have been invalidated on server")
						LoginHelper.logout()
					}
				})
		}
	}
}

