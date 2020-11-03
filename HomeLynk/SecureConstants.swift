//
//  SecureConstants.swift
//  HomeLynk
//
//  Created by Ivan Dilchovski on 1/28/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation

//This class is for storing sensitive constants, such as usernames and passwords, private links, etc
//It is added to .gitignore after it's initial commit
struct SecureConstants
{
    struct Accounts
    {
        struct NYRets
        {
            static let username = "mpollack"
            static let password = "zAc4ST7A"
        }
        
        struct Google
        {
            static let placesAPIKey = "AIzaSyBf-HOSjDyIFNvEruPRYgmIxn4OThopXMY"
        }
    }
}