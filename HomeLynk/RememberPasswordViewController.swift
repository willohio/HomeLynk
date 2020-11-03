//
//  RememberPasswordViewController.swift
//  HomeLynk
//
//  Created by Ivan Dilchovski on 1/12/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import UIKit

class RememberPasswordViewController: UIViewController
{
	
	@IBOutlet var emailField: UITextField!
	@IBOutlet var rememberButton: UIButton!
	@IBOutlet var activityIndicator: UIActivityIndicatorView!
	
	@IBAction func emailChanged(sender: UITextField)
	{
		if let text = emailField.text where text.isEmail
		{
			rememberButton.enabled = true
		} else
		{
			rememberButton.enabled = false
		}
	}
	
	@IBAction func rememberPressed(sender: UIButton)
	{
		activityIndicator.startAnimating()
		HLPasswordResetRequest.requestResetForEmail(emailField.text!,
			successHandler: { () -> () in
				self.activityIndicator.stopAnimating()
				let alertController = UIAlertController(title: "Password reset link set", message: "A password reset link have been sent to your email.", preferredStyle: .Alert)
				let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
				alertController.addAction(okAction)
				
				self.presentViewController(alertController, animated: true, completion: nil)
			}, failureHandler: { (error) -> () in
				self.activityIndicator.stopAnimating()
				switch error
				{
					case .NoConnection:
						let alertController = UIAlertController(title: "No Network", message: "No network connection!", preferredStyle: .Alert)
						let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
						alertController.addAction(okAction)
						
						self.presentViewController(alertController, animated: true, completion: nil)
						log.error("No connection")
					
					case .StatusCode(let statusCode, _):
						if statusCode == 404
						{
							let alertController = UIAlertController(title: "Email not found", message: "No user with the given email address was found.", preferredStyle: .Alert)
							let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
							alertController.addAction(okAction)
							
							self.presentViewController(alertController, animated: true, completion: nil)
						}
					default:
						let alertController = UIAlertController(title: "Error", message: "There was an error when trying to send the password request link. Please try again.", preferredStyle: .Alert)
						let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
						alertController.addAction(okAction)
						
						self.presentViewController(alertController, animated: true, completion: nil)

				}
		})
	}
	
    override func viewDidLoad()
	{
        super.viewDidLoad()

        rememberButton.layer.cornerRadius = 5
    }

    override func didReceiveMemoryWarning()
	{
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
