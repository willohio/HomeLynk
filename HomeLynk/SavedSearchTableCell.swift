//
//  SavedSearchTableCell.swift
//  HomeLynk
//
//  Created by William Santiago on 1/21/16.
//  Copyright © 2016 William Santiago. All rights reserved.
//

import UIKit

class SavedSearchTableCell: UITableViewCell
{
	@IBOutlet var trashButton: UIButton!
	
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var searchParamsLabel: UILabel! //Price range, beds, baths, size
	@IBOutlet var propertyTypeLabel: UILabel!
	@IBOutlet var savedOnLabel: UILabel!
	@IBOutlet var totalLabel: UILabel!
	
	@IBOutlet var separatorHeight: NSLayoutConstraint!
	
	@IBOutlet var deleteButton: UIButton!
	@IBOutlet var bustaButton: UIButton!
	
	override func awakeFromNib()
	{
		separatorHeight.constant = 0.5 //IB does not allow constant < 1. May be an issue on non-retina devices (iPad 2, iPad Mini 1/2)
	}
}
