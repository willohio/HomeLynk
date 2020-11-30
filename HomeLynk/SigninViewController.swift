//
//  SigninViewController.swift
//  HomeLynk
//
//  Created by William Santiago on 1/12/16.
//  Copyright © 2016 William Santiago. All rights reserved.
//

import UIKit
import ViewDeck

class SigninViewController: UIViewController
{
	@IBOutlet var emailField: UITextField!
	@IBOutlet var passwordField: UITextField!

	@IBOutlet var signInButton: UIButton!
	
	@IBOutlet var textFieldsHeightConstraint: NSLayoutConstraint!
	@IBOutlet var buttonsHeightConstraint: NSLayoutConstraint!
	
	@IBOutlet var activityIndicator: UIActivityIndicatorView!
	
	@IBAction func signInPressed(sender: UIButton)
	{
		guard let email = emailField.text, password = passwordField.text
			else
		{
			return
		}
		
		activityIndicator.startAnimating()
		
		LoginHelper.loginWithEmail(email, password: password, rememberMe: true,
			successHandler: { (user) -> () in
				UIView.animateWithDuration(Constants.Values.animationDurationShort) { () -> Void in
					self.activityIndicator.stopAnimating()
				}
				
				NYRetsLoginRequest.login(
					username: SecureConstants.Accounts.NYRets.username,
					password: SecureConstants.Accounts.NYRets.password,
					successHandler: nil,
					failureHandler: { (error) -> () in
				})
				
				self.loginUser(user)
			},
			failureHandler: { (error) -> () in
				UIView.animateWithDuration(Constants.Values.animationDurationShort) { () -> Void in
					self.activityIndicator.stopAnimating()
				}
				
				self.handleLoginError(error)
		})
	}
	
	@IBAction func forgotPressed(sender: UIButton)
	{
	}
	
	@IBAction func signInFacebook(sender: UIButton)
	{
	}
	
	
    override func viewDidLoad()
	{
        super.viewDidLoad()

		self.view.bringSubviewToFront(activityIndicator)
		
		self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil) //Removes the title from the back button on the next screen
		
		signInButton.layer.cornerRadius = 5
    }

	override func viewWillAppear(animated: Bool)
	{
		super.viewWillAppear(animated)
		
		self.navigationController?.setNavigationBarHidden(false, animated: true)
	}
	
    override func didReceiveMemoryWarning()
	{
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	// MARK: - Private
	private func loginUser(user: HLUser)
	{
		HLUser.currentUser = user

		let mainNavController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(Constants.StoryboardIds.MainNavigationController)
		let leftMenuController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(Constants.StoryboardIds.LeftMenuViewController)
		let deckController = IIViewDeckController(centerViewController: mainNavController, leftViewController: leftMenuController)
		
		let delegate = UIApplication.sharedApplication().delegate as? AppDelegate
		delegate?.window?.rootViewController = deckController
	}
	
	private func handleLoginError(error: RequestError)
	{
		HLUser.currentUser = nil
		
		//No difference for the user between wrong email/pass and no such user found
		if case .StatusCode(let statusCode, _) = error where statusCode == 401 || statusCode == 404
		{
			LoginHelper.logout() // Delete any stored email and token, as they are invalid
		}
		
		self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
		

	}


}
