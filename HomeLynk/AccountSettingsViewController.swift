//
//  AccountSettingsViewController.swift
//  HomeLynk
//
//  Created by Ivan Dilchovski on 1/15/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import UIKit

class AccountSettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIScrollViewDelegate, UITextFieldDelegate
{
	// MARK: - Outlets
	
	@IBOutlet var firstNameField: UITextField!
	@IBOutlet var lastNameField: UITextField!
	@IBOutlet var emailField: UITextField!
	@IBOutlet var phoneField: UITextField!
	@IBOutlet var ageButton: UIButton!
	@IBOutlet var agePicker: UIPickerView!
	
	@IBOutlet var passwordField: UITextField!
	@IBOutlet var passwordAgainField: UITextField!
	
	@IBOutlet var separatorHeightConstraints: [NSLayoutConstraint]!
	@IBOutlet var agePickerHiddenConstraint: NSLayoutConstraint!
	
	@IBOutlet var saveChangesButton: UIButton!
	@IBOutlet var logOutButton: UIButton!
	
	@IBOutlet var activityIndicator: UIActivityIndicatorView!
	
	
	// MARK: - Actions
	
	@IBAction func textFieldChanged(sender: UITextField)
	{
		saveChangesButton.enabled = true
		
		if let password = passwordField.text, passwordAgain = passwordAgainField.text //If both pass fields have text
		{
			if password != passwordAgain
			{
				saveChangesButton.enabled = false
			}
		} else if (passwordField.text == nil && passwordAgainField.text != nil) || (passwordField.text != nil && passwordAgainField.text == nil)
		{
			saveChangesButton.enabled = false
		}
		
		if let firstName = firstNameField.text where firstName == ""
		{
			saveChangesButton.enabled = false
		}
		
		if let lastNameField = firstNameField.text where lastNameField == ""
		{
			saveChangesButton.enabled = false
		}
		
		if let emailField = firstNameField.text where emailField == ""
		{
			saveChangesButton.enabled = false
		}
		
		if firstNameField.text == nil ||
			lastNameField.text == nil ||
			emailField.text == nil
		{
			saveChangesButton.enabled = false
		}
		
		if let email = emailField.text where !email.isEmail
		{
			saveChangesButton.enabled = false
		}
	}
	
	
	@IBAction func agePressed(sender: UIButton)
	{
		if !agePickerHiddenConstraint.active
		{
			agePickerHiddenConstraint.active = true
			UIView.animateWithDuration(Constants.Values.animationDurationMedium, animations: { () -> Void in
				self.view.layoutIfNeeded()
			})
		}
	}
	
	@IBAction func saveChangesPressed(sender: UIButton)
	{
		activityIndicator.startAnimating()
		let user = HLUser.currentUser!
		user.email = emailField.text!
		user.firstName = firstNameField.text!
		user.lastName = lastNameField.text!
		if let phone = phoneField.text
		{
			user.phone = phone
		}
		
		HLUserRequests.updateUser(user,
			password: passwordField.text!,
			passwordConfirmation: passwordAgainField.text!,
			successHandler: { (user) -> () in
				self.activityIndicator.stopAnimating()
				
				HLUser.currentUser = user
				
				let alertController = UIAlertController(title: "Account successfully updated", message: nil, preferredStyle: .Alert)
				let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
				alertController.addAction(okAction)
				
				self.presentViewController(alertController, animated: true, completion: nil)
				
			}, failureHandler: { (error) -> () in
				self.activityIndicator.stopAnimating()
				
				let alertController = UIAlertController(title: "Could not update account", message: "There was an error when updating the account data. Please try again.", preferredStyle: .Alert)
				let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
				alertController.addAction(okAction)
				
				self.presentViewController(alertController, animated: true, completion: nil)
		})
	}
	
	@IBAction func logOutPressed(sender: UIButton)
	{
		LoginHelper.logout()
		
		let loginNavController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(Constants.StoryboardIds.LoginNavigationController)
		let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
		
		delegate.window?.rootViewController = loginNavController
	}
	
	
	// MARK: - Lifecycle
	
    override func viewDidLoad()
	{
        super.viewDidLoad()
		
		guard let currentUser = HLUser.currentUser
			else
		{
			fatalError("AccountSettings should be disabled when no user is logged in.")
		}
		
		firstNameField.text = currentUser.firstName
		lastNameField.text = currentUser.lastName
		emailField.text = currentUser.email
		if let phone = currentUser.phone
		{
			phoneField.text = "\(phone)"
		}
		
		if let age = currentUser.age
		{
			ageButton.setTitle(age, forState: .Normal)
			ageButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
			ageButton.titleLabel?.font = UIFont.systemFontOfSize(14)
			for (index, ageRange) in HLUser.ageRanges.enumerate()
			{
				if ageRange == age
				{
					agePicker.selectRow(index, inComponent: 0, animated: false)
				}
			}
		}
		
		ageButton.contentHorizontalAlignment = .Right
		
		saveChangesButton.layer.cornerRadius = 5
		saveChangesButton.setTitleColor(UIColor.lightTextColor(), forState: UIControlState.Disabled)
		
		logOutButton.layer.cornerRadius = 5
		logOutButton.layer.borderWidth = 1
		logOutButton.layer.borderColor = Constants.Colors.LightBlue.CGColor
		
		for height in separatorHeightConstraints
		{
			height.constant = 0.5
		}
    }
	
	// MARK: - UIPickerViewDelegate
	
	func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int
	{
		return 1
	}
	
	func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
	{
		return HLUser.ageRanges.count
	}
	
	func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
	{
		return HLUser.ageRanges[row]
	}
	
	func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
	{
		ageButton.setTitle(HLUser.ageRanges[row], forState: .Normal)
		ageButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
		ageButton.titleLabel?.font = UIFont.systemFontOfSize(14)
	}

	
	// MARK: - UIScrollViewDelegate
	
	func scrollViewWillBeginDragging(scrollView: UIScrollView)
	{
		if agePickerHiddenConstraint.active
		{
			agePickerHiddenConstraint.active = false
			UIView.animateWithDuration(Constants.Values.animationDurationMedium, animations: { () -> Void in
				self.view.layoutIfNeeded()
			})
		}
	}

	
	// MARK: - UITextFieldDelegate
	func textFieldShouldBeginEditing(textField: UITextField) -> Bool
	{
		if agePickerHiddenConstraint.active
		{
			agePickerHiddenConstraint.active = false
			UIView.animateWithDuration(Constants.Values.animationDurationMedium, animations: { () -> Void in
				self.view.layoutIfNeeded()
			})
		}
		
		return true
	}
	
}
