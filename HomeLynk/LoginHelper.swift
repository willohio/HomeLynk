//
//  LoginHelper.swift
//  HomeLynk
//
//  Created by Ivan Dilchovski on 1/23/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation

import Locksmith
import Alamofire

class LoginHelper
{
	private static let keychainAccount = "HomeLynk"
	private static let keychainEmailKey = "email"
	private static let keychainTokenKey = "token"
	
	class func loginWithKeychain(successHandler success: ((user: HLUser) -> ())?, failureHandler failure: ((error: RequestError) -> ())?)
	{
		if let (email, token) = LoginHelper.getEmailAndTokenFromKeychain()
		{
			HLSessionRequest.verifyToken(token, email: email, successHandler: { (user) -> () in
					success?(user: user)
					HLUser.currentUser = user
					HLUser.currentUserAuthToken = token
				},
				failureHandler: { (requestError) -> () in
					failure?(error: requestError)
			})
		} else
		{
			failure?(error: RequestError.StatusCode(statusCode: 401, message: nil))
		}
		
	}
	
	class func loginWithEmail(email: String, password: String, rememberMe: Bool, successHandler success: ((user: HLUser) -> ())?, failureHandler failure: ((error: RequestError) -> ())?)
	{
		HLSessionRequest.login(
			email: email,
			password: password,
			successHandler: { (user) -> () in
				if let token = user.authToken
				{
					HLUser.currentUserAuthToken = token
					do
					{
						if rememberMe
						{
							if var loginData = Locksmith.loadDataForUserAccount(keychainAccount)
							{
								loginData[keychainTokenKey] = token
								loginData[keychainEmailKey] = email
								try Locksmith.updateData(loginData, forUserAccount: keychainAccount)
							} else
							{
								var loginData = [String : AnyObject]()
								loginData[keychainTokenKey] = token
								loginData[keychainEmailKey] = email
								
								try Locksmith.saveData(loginData, forUserAccount: keychainAccount)
							}
						} else
						{
							try Locksmith.deleteDataForUserAccount(keychainAccount) // Delete to be sure there is no old data in the keychain.
						}
					} catch let error as LocksmithError
					{
						log.error("Error while storing auth token to keychain \(error.rawValue)")
					} catch
					{
						log.error("Unknown error while storing auth token to keychain")
					}
				}
				
				success?(user: user)
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
	
	class func logout()
	{
		HLUser.currentUserAuthToken = nil
		HLUser.currentUser = nil
		
		do
		{
			try Locksmith.deleteDataForUserAccount(keychainAccount)
		} catch let error as LocksmithError
		{
			log.error("Error while deleteing account data from keychain \(error.rawValue)")
		} catch
		{
			log.error("Unknown error while deleteing account data from keychain")
		}
	}
	
	class func getEmailAndTokenFromKeychain() -> (email: String, token: String)?
	{
		if let loginData = Locksmith.loadDataForUserAccount(keychainAccount), token = loginData[keychainTokenKey] as? String, email = loginData[keychainEmailKey] as? String
		{
			return (email, token)
		} else
		{
			return nil
		}
	}
}