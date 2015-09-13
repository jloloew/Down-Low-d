//
//  AppDelegate.swift
//  Down Low'd
//
//  Created by Justin Loew on 9/12/15.
//  Copyright © 2015 Justin Loew. All rights reserved.
//

import UIKit
import WatchConnectivity
import CoreLocation
import Contacts

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
	private var wcsess: WCSession!
	let locManager = CLLocationManager()
	let communicator = Communicator()
	var currentName: String! { return (window!.rootViewController as! ViewController).nameField.text }
	
	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		guard WCSession.isSupported() else {
			return false
		}
		
		wcsess = WCSession.defaultSession()
		wcsess.delegate = self
		wcsess.activateSession()
		
		// set up location services
		locManager.delegate = self
		if CLLocationManager.authorizationStatus() == .NotDetermined {
			locManager.requestAlwaysAuthorization()
		}
		
		return true
	}
	
	func applicationWillResignActive(application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}
	
	func applicationDidEnterBackground(application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}
	
	func applicationWillEnterForeground(application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}
	
	func applicationDidBecomeActive(application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}
	
	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}
	
}

extension AppDelegate: WCSessionDelegate {
	func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
		print("received message from watch: \(message)")
		
		// ignore the message if we're already talking to the server
//		guard communicator == nil else {
//			print("ignoring message because we're already talking to the server")
//			return
//		}
		
		// add location info
		guard let _ = locManager.location else {
			print("Can't get location")
			return
		}
		var msgDict = message
//		msgDict["location"] = [
//			"lat": loc.coordinate.latitude,
//			"lon": loc.coordinate.longitude
//		]
		msgDict["location"] = [
			"lat": 42.275555556,
			"lon": -83.731388889
		]
		
		// send to server
		communicator.delegate = self
		communicator.sendDict(msgDict)
	}
}

extension AppDelegate: CLLocationManagerDelegate {
	func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
		if status == .AuthorizedWhenInUse || status == .AuthorizedAlways {
			locManager.startUpdatingLocation()
		}
	}
}

extension AppDelegate: CommunicatorDelegate {
	func communicatorGetDataForSharing(_: Communicator) -> [String : AnyObject] {
		return [
			"type": "contact",
			"name": currentName,
//			"given name": "Richard",
//			"family name": "Stallman",
			"phone": "867-5309",
			"phonetype": CNLabelPhoneNumberMobile,
			"email": "Ho-Ho_lover@aol.com",
			"emailtype": CNLabelHome,
			"note": "You can use any editor you want, but remember that vi vi vi is the text editor of the beast."
//			,"image": UIImagePNGRepresentation(UIImage(named: "stallman")!)!
		]
	}
		/*
		// TODO: put this on another thread
		let store = CNContactStore()
		let predicate = CNContact.predicateForContactsMatchingName("Richard Stallman")
		let mostKeys = [CNContactBirthdayKey, CNContactDatesKey, CNContactDepartmentNameKey, CNContactEmailAddressesKey, CNContactFamilyNameKey, CNContactGivenNameKey, CNContactIdentifierKey, CNContactImageDataAvailableKey, CNContactImageDataKey, CNContactInstantMessageAddressesKey, CNContactJobTitleKey, CNContactMiddleNameKey, CNContactNamePrefixKey, CNContactNameSuffixKey, CNContactNicknameKey, CNContactNonGregorianBirthdayKey, CNContactNoteKey, CNContactOrganizationNameKey, CNContactPhoneNumbersKey, CNContactPhoneticFamilyNameKey, CNContactPhoneticGivenNameKey, CNContactPhoneticMiddleNameKey, CNContactPostalAddressesKey, CNContactPreviousFamilyNameKey, CNContactRelationsKey, CNContactSocialProfilesKey, CNContactThumbnailImageDataKey, CNContactTypeKey, CNContactUrlAddressesKey]
		do {
			let contacts = try store.unifiedContactsMatchingPredicate(predicate, keysToFetch: mostKeys)
			if let contact = contacts.first {
				let vcardData = try CNContactVCardSerialization.dataWithContacts([contact])
				return ("vcf", vcardData)
			}
			
//			if contacts.count > 0 {
//				let fetchRequest = CNContactFetchRequest(keysToFetch: mostKeys)
//				var vcardData = NSData()
//				
//				try store.enumerateContactsWithFetchRequest(fetchRequest, usingBlock: { (contact, _) -> Void in
//					do {
//						vcardData = try CNContactVCardSerialization.dataWithContacts([contact])
//					} catch {
//						print("haha...I'm right \(error)")
//					}
//				})
//				return ("vcf", vcardData)
//			}
		} catch {
			print(error)
		}
		print("Error getting contact card for user")
		return ("vcf", NSData())
	}
	*/
	
	func communicator(comm: Communicator, didReceiveSharedData data: [String : AnyObject]) {
		if data["type"] as! String == "contact" {
			// create contact with the info
			let contact = CNMutableContact()
			contact.givenName = data["name"] as! String
//			contact.givenName = data["given name"] as! String
//			contact.familyName = data["family name"] as! String
			contact.phoneNumbers = [CNLabeledValue(label: (data["phonetype"] as! String), value: CNPhoneNumber(stringValue: data["phone"] as! String))]
			contact.emailAddresses = [CNLabeledValue(label: (data["emailtype"] as! String), value: data["email"] as! String)]
			contact.note = data["note"] as! String
//			contact.imageData = data["image"] as? NSData
			contact.imageData = UIImagePNGRepresentation(UIImage(named: "stallman")!)!
			// save the new contact
			let store = CNContactStore()
			let saveRequest = CNSaveRequest()
			saveRequest.addContact(contact, toContainerWithIdentifier: nil)
			do {
				try store.executeSaveRequest(saveRequest)
				(window!.rootViewController as! ViewController).didSaveContact()
				print("Saved contact")
			} catch {
				print("Unable to save contact: \(error)")
			}
		} else if data["type"] as! String == "LinkedIn" {
			let username = data["usernqme"] as! String
			// friend him on LinkedIn
			let profileURL = NSURL(string: "https://linkedin.com/in/" + username)!
			UIApplication.sharedApplication().openURL(profileURL)
		} else {
			print("Unknown type")
		}
	}
	
	func communicatorDidFinishTransmittingData(_: Communicator) {
		wcsess.sendMessage(["doneTransmittingData": true], replyHandler: nil, errorHandler: nil)
	}
}
