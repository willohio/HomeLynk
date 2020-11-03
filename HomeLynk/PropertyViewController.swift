//
//  PropertyViewController.swift
//  HomeLynk
//
//  Created by Ivan Dilchovski on 1/13/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import UIKit
import MessageUI

import Alamofire

//UINavigationControllerDelegate is required for MFMailComposeViewControllerDelegate
class PropertyViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate
{
	// MARK: - Properties
	
	var property: HLProperty!
	
	// MARK: - Private
	
	private var hasLoadedPictures = false
	
	private var getPicturesRequest: Alamofire.Request?
	
	// MARK: - Outlets
	
	@IBOutlet var contactAgentButton: UIButton!
	
	@IBOutlet var imagesCollectionView: UICollectionView!
	
	@IBOutlet var addressLabel: UILabel!
	@IBOutlet var forSaleLabel: UILabel!
	@IBOutlet var bedsBathsSizeLabel: UILabel!
	@IBOutlet var priceLabel: UILabel!
	@IBOutlet var lotSizeLabel: UILabel!
	
	@IBOutlet var saveButton: UIButton!
	
	@IBOutlet var separatorHeights: [NSLayoutConstraint]!
	
	// MARK: - Actions
	@IBAction func contactAgentPressed(sender: UIButton)
	{
		guard let agentId = property.agentId
			else
		{
			let alertController = UIAlertController(title: "Could not get agent contact information", message: nil, preferredStyle: .Alert)
			let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
			alertController.addAction(okAction)
			
			self.presentViewController(alertController, animated: true, completion: nil)
			log.error("No agent id for property with mlsid: \(property.id)")
			
			return
		}
		
		NYRetsProvider.getAgentsWithIds([agentId],
			successHandler: { (agents) -> () in
				if let agent = agents.first, agentEmail = agent.email
				{
					let mailComposer = MFMailComposeViewController()
					mailComposer.delegate = self
					mailComposer.setToRecipients([agentEmail])
					mailComposer.setSubject("Property \(self.property.id!) enquiry")
					
					self.presentViewController(mailComposer, animated: true, completion: nil)
				}
			},
			failureHandler: { (requestError) -> () in
				self.presentViewController(requestError.getGenericAlert(), animated: true, completion: nil)
			})
	}
	
	@IBAction func savePressed(sender: UIButton)
	{
		guard HLUser.currentUser != nil
			else
		{
			log.error("Only a logged in user can save properties!")
			return
		}
		
		saveButton.setTitleColor(UIColor.lightTextColor(), forState: .Disabled)
		saveButton.enabled = false
		
		HLUsersSavedPropertiesRequest.saveProperty(property.id!,
			successHandler: { () -> () in
				log.info("Success")
			},
			failureHandler: { (error) -> () in
				self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
		})
	}
	
	@IBAction func hidePressed(sender: UIButton)
	{
		Settings.User.hiddenProperties.append(property.id!)
		self.navigationController?.popViewControllerAnimated(true)
	}
	
	@IBAction func mapPressed(sender: UIButton)
	{
		let mapVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(Constants.StoryboardIds.MapViewController) as! MapViewController
		
		mapVC.isNotHomeScreen = true
		mapVC.properties = [property]
		self.navigationController?.pushViewController(mapVC, animated: true)
		
		mapVC.navigationItem.rightBarButtonItem = nil
	}
	
	
	// MARK: - Lifecycle
	
    override func viewDidLoad()
	{
        super.viewDidLoad()

		self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil) //Removes the title from the back button on the next screen
		
		saveButton.enabled = property.id != nil && HLUser.currentUser != nil
		contactAgentButton.enabled = property.agentId != nil
		
		let decimalFormatter = NSNumberFormatter()
		decimalFormatter.numberStyle = .DecimalStyle
		
		//Add spacing between button and image
		contactAgentButton.setImageSpacing(4)
		let insets = contactAgentButton.contentEdgeInsets
		contactAgentButton.contentEdgeInsets = UIEdgeInsets(top: insets.top + 8, left: insets.left + 8, bottom: insets.bottom + 8, right: insets.right + 8)
		contactAgentButton.layer.cornerRadius = 5
		
		addressLabel.text = property.address ?? "n/a"
		
		let bedsString: String
		if let propertyBeds = property.beds
		{
			bedsString = "\(propertyBeds)"
		} else
		{
			bedsString = "n/a"
		}
		
		let bathsString: String
		if let propertyBaths = property.baths
		{
			bathsString = "\(propertyBaths)"
		} else
		{
			bathsString = "n/a"
		}
		
		let sizeString: String
		if let propertySize = property.size
		{
			sizeString = decimalFormatter.stringFromNumber(propertySize)!
		} else
		{
			sizeString = "n/a"
		}
		
		let lotSizeString: String
		if let lotSize = property.lotSize
		{
			lotSizeString = decimalFormatter.stringFromNumber(lotSize)! + " sqft"
		} else
		{
			lotSizeString = "n/a"
		}
		
		
		let priceString: String
		if let propertyPrice = property.price
		{
			priceString = decimalFormatter.stringFromNumber(propertyPrice)!
		} else
		{
			priceString = "n/a"
		}
		
		bedsBathsSizeLabel.text = "\(bedsString) beds - \(bathsString) baths - \(sizeString) sqft"
		priceLabel.text = "$\(priceString)"
		lotSizeLabel.text = lotSizeString
		
//		for height in separatorHeights
//		{
//			height.constant  = 0.5
//		}
		
		if let images = property.propertyImages where images.count < 2 && property.id != nil
		{
			hasLoadedPictures = false
		} else if property.propertyImages == nil && property.id != nil
		{
			hasLoadedPictures = false
		}
		
		if !hasLoadedPictures
		{
			getPicturesRequest = NYRetsGetObjectRequest.getPhotosForPropertyIds([property.id!],
				firstPhotoOnly: false,
				successHandler: { (photosData) -> () in
					if let photosData = photosData[self.property.id!]
					{
						self.hasLoadedPictures = true
						self.property.propertyImages = photosData.map { UIImage(data: $0) }.flatMap{ $0 } //Filter out non-image data
						self.imagesCollectionView.reloadData()
					} else
					{
						log.error("Could not load images")
					}
					
					self.getPicturesRequest = nil
				},
				failureHandler: { (requestError) -> () in
					switch requestError // requestError can not be directly compared with .Cancelled due to associated values in the enum cases
					{
						case .Cancelled: ()
						default: self.presentViewController(requestError.getGenericAlert(), animated: true, completion: nil)
					}
					
					self.getPicturesRequest = nil
			})
		}
    }

	override func viewWillDisappear(animated: Bool)
	{
		super.viewWillDisappear(animated)
		
		getPicturesRequest?.cancel()
	}
	
	deinit
	{
		log.info("Deinit")
	}
	
    override func didReceiveMemoryWarning()
	{
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
	{
		if let segueId = segue.identifier
			where segueId == Constants.SegueIds.contactPropertyAgent
		{
		}
	}
	
	// MARK: - UICollectionViewDataSource
	
	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
	{
		return hasLoadedPictures ? 1 : 2 // Second section with loading indicator if not all photos have been loade
	}
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
	{
		return section == 0 ? (property.propertyImages?.count ?? 0) : 1
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
	{
		if indexPath.section == 0
		{
			let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CellIds.propertyImageCell, forIndexPath: indexPath) as! PropertyViewImageCollectionCell
			
			let image = property.propertyImages![indexPath.row]
			cell.upperImageView.image = image
			cell.lowerImageView.image = image
			
			return cell
		} else
		{
			return collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CellIds.propertyImageLoadingCell, forIndexPath: indexPath)
		}
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
	{
		return CGSizeMake(self.view.frame.width, self.view.frame.height)
	}

	// MARK: - MFMailComposeViewControllerDelegate
	func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?)
	{
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
}
