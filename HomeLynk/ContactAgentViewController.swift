//
//  ContactAgentViewController.swift
//  HomeLynk
//
//  Created by William Santiago on 1/14/16.
//  Copyright © 2016 William Santiago. All rights reserved.
//

import UIKit
import M13Checkbox

class ContactAgentViewController: UIViewController
{
	
	@IBOutlet weak var phoneField: UITextField!
	@IBOutlet weak var visitCheckbox: M13Checkbox!
	@IBOutlet weak var sendButton: UIButton!
	
	@IBOutlet weak var questionsTextView: UITextView!
	
	
	@IBAction func sendPressed(sender: UIButton)
	{
	}
	
    override func viewDidLoad()
	{
        super.viewDidLoad()
		
		questionsTextView.layer.cornerRadius = 5
		questionsTextView.layer.borderColor = UIColor.lightGrayColor().CGColor
		questionsTextView.layer.borderWidth = 0.5
		
		visitCheckbox.titleLabel.text = "I want to visit this home"
		visitCheckbox.titleLabel.textColor = UIColor.blackColor()
		visitCheckbox.titleLabel.font = UIFont.systemFontOfSize(14)
		
		visitCheckbox.uncheckedColor = UIColor.whiteColor()
		visitCheckbox.checkColor = Constants.Colors.LightBlue
		visitCheckbox.strokeColor = Constants.Colors.LightBlue
		
		visitCheckbox.checkAlignment = M13CheckboxAlignmentLeft
		
		sendButton.layer.cornerRadius = 5
    }

    override func didReceiveMemoryWarning()
	{
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
