//
//  SignupViewController.swift
//  HomeLynk
//
//  Created by William Santiago on 1/11/16.
//  Copyright © 2016 William Santiago. All rights reserved.
//

import UIKit
import SwiftyJSON

class SignupViewController: UIViewController, UIScrollViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource
{
	// MARK: - Properties
	
	private var ageSelected = false
	
	
	// MARK: - Outlets
	
	@IBOutlet var firstNameField: UITextField!
	@IBOutlet var lastNameField: UITextField!
	@IBOutlet var ageField: UITextField!
	@IBOutlet var agePicker: UIPickerView!
	@IBOutlet var emailField: UITextField!
	@IBOutlet var phoneField: UITextField!

	@IBOutlet var passwordField: UITextField!
	@IBOutlet var passwordConfirmField: UITextField!
	
	@IBOutlet var signUpButton: UIButton!
	
	@IBOutlet var privacyPolicyButton: UIButton!
	@IBOutlet var termsButton: UIButton!
	
	@IBOutlet var agePickerVisibleConstraint: NSLayoutConstraint!
	
	@IBOutlet var activityIndicator: UIActivityIndicatorView!
	
	
	// MARK: - Actions
	
	@IBAction func editingChanged(sender: UITextField)
	{
		signUpButton.enabled = validateInput()
	}
	
	@IBAction func signUpPressed(sender: UIButton)
	{
		guard let firstName = firstNameField.text,
				lastName = lastNameField.text,
				email = emailField.text,
				age = ageField.text,
				password = passwordField.text,
				passwordConfirm = passwordConfirmField.text
			where firstName != "" &&
				lastName != "" &&
				email != "" &&
				age != "" &&
				password != "" &&
				passwordConfirm != "" &&
				password == passwordConfirm
			else
		{
			return
		}
		
		activityIndicator.startAnimating()
		
		let user = HLUser()
		user.email = emailField.text!
		user.firstName = firstNameField.text!
		user.lastName = lastNameField.text!
		user.age = age
		if let phone = phoneField.text
		{
			user.phone = phone
		}
		
		HLUserRequests.createNewUser(user,
			password: passwordField.text!,
			passwordConfirmation: passwordConfirmField.text!,
			successHandler: { (user) -> () in
				self.activityIndicator.stopAnimating()
				HLUser.currentUser = user
				
				let alertController = UIAlertController(title: "Account successfully created", message: "You can now login with your new account", preferredStyle: .Alert)
				let okAction = UIAlertAction(title: "Awesome!", style: .Default) { (action) -> Void in
					self.navigationController?.popViewControllerAnimated(true)
				}
				alertController.addAction(okAction)
				
				self.presentViewController(alertController, animated: true, completion: nil)
			}, failureHandler: { (error) -> () in
				self.activityIndicator.stopAnimating()
				
				if case .StatusCode(let statusCode, let message) = error where statusCode == 422
				{
					let alertController = UIAlertController(title: "Could not create your account", message: message, preferredStyle: .Alert)
					let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
					alertController.addAction(okAction)
					
					self.presentViewController(alertController, animated: true, completion: nil)
				} else
				{
					self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
				}
		})
	}
	
	
	// MARK: - Lifecycle
	
    override func viewDidLoad()
	{
        super.viewDidLoad()

		self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil) //Removes the title from the back button on the next screen
		
		signUpButton.setTitleColor(UIColor.lightTextColor(), forState: UIControlState.Disabled)
		signUpButton.enabled = false
		
		firstNameField.delegate = self
		lastNameField.delegate = self
		ageField.delegate = self
		emailField.delegate = self
		phoneField.delegate = self
		
		passwordField.delegate = self
		passwordConfirmField.delegate = self
		
		signUpButton.layer.cornerRadius = 5
		
		let attributes = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
		let privacyAttributedText = NSAttributedString(string: privacyPolicyButton.currentTitle!, attributes: attributes)
		let termsAttributedText = NSAttributedString(string: termsButton.currentTitle!, attributes: attributes)
		
		privacyPolicyButton.setAttributedTitle(privacyAttributedText, forState: .Normal)
		termsButton.setAttributedTitle(termsAttributedText, forState: .Normal)
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
    

    // MARK: - UITextFieldDelegate
	func textFieldShouldBeginEditing(textField: UITextField) -> Bool
	{
		if textField == ageField
		{
			if !agePickerVisibleConstraint.active
			{
				self.view.endEditing(true)
				agePickerVisibleConstraint.active = true
				UIView.animateWithDuration(Constants.Values.animationDurationMedium, animations: { () -> Void in
					self.view.layoutIfNeeded()
				})
			}
			
			return false
		}
		
		if agePickerVisibleConstraint.active
		{
			agePickerVisibleConstraint.active = false
			UIView.animateWithDuration(Constants.Values.animationDurationMedium, animations: { () -> Void in
				self.view.layoutIfNeeded()
			})
		}
		
		return true
	}
	
	
	// MARK: - UIScrollViewDelegate
	
	func scrollViewWillBeginDragging(scrollView: UIScrollView)
	{
		if agePickerVisibleConstraint.active
		{
			agePickerVisibleConstraint.active = false
			UIView.animateWithDuration(Constants.Values.animationDurationMedium, animations: { () -> Void in
				self.view.layoutIfNeeded()
			})
		}
	}
	
	
	// MARK: - UIPickerViewDataSource
	
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
		ageSelected = true
		ageField.text = HLUser.ageRanges[row]
	}
	
	
	// MARK: - Private
	
	func validateInput() -> Bool
	{
		var isValid = true
		
		if let firstName = firstNameField.text
		{
			if firstName == ""
			{
				isValid = false
			} else
			{
				var firstName = firstName
				firstName.replaceRange(firstName.startIndex...firstName.startIndex, with: String(firstName[firstName.startIndex]).capitalizedString)
				firstNameField.text = firstName
			}
		}
		
		if let lastName = lastNameField.text
		{
			if lastName == ""
			{
				isValid = false
			} else
			{
				var lastName = lastName
				lastName.replaceRange(lastName.startIndex...lastName.startIndex, with: String(lastName[lastName.startIndex]).capitalizedString)
				lastNameField.text = lastName
			}
		}
		
		if !ageSelected
		{
			isValid = false
		}
		
		if let email = emailField.text where email == ""
		{
			isValid = false
		}
		
		if firstNameField.text == nil ||
			lastNameField.text == nil ||
			emailField.text == nil
		{
			isValid = false
		}
		
		if let email = emailField.text where !email.isEmail
		{
			isValid = false
		}
		
		if let password = passwordField.text, passwordAgain = passwordConfirmField.text //If both pass fields have text
		{
			if password != passwordAgain
			{
				isValid = false
			}
		} else
		{
			isValid = false
		}
		
		return isValid
	}
}
