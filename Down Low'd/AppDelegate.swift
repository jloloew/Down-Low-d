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
	var communicator: Communicator?
	
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
		guard communicator == nil else {
			print("ignoring message because we're already talking to the server")
			return
		}
		
		// add location info
		guard let loc = locManager.location else {
			print("Can't get location")
			return
		}
		var msgDict = message
		msgDict["location"] = [
			"lat": loc.coordinate.latitude,
			"lon": loc.coordinate.longitude
		]
		
		// send to server
		communicator = Communicator()
		let com = communicator!
		com.delegate = self
		com.sendDict(msgDict)
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
	func communicatorGetDataForSharing(_: Communicator) -> (type: String, data: AnyObject) {
		// TODO: put this on another thread
		let store = CNContactStore()
		let predicate = CNContact.predicateForContactsMatchingName("Justin Loew")
		if let contactOpt = try? store.unifiedContactsMatchingPredicate(predicate, keysToFetch: [CNContactEmailAddressesKey, CNContactFamilyNameKey, CNContactGivenNameKey, CNContactImageDataAvailableKey, CNContactImageDataKey, CNContactJobTitleKey, CNContactMiddleNameKey, CNContactNamePrefixKey, CNContactNameSuffixKey, CNContactNicknameKey, CNContactOrganizationNameKey, CNContactPhoneNumbersKey, CNContactPostalAddressesKey, CNContactSocialProfilesKey, CNContactThumbnailImageDataKey, CNContactTypeKey, CNContactUrlAddressesKey]).first,
			contact = contactOpt,
			vcardData = try? CNContactVCardSerialization.dataWithContacts([contact])
		{
			return ("vcf", vcardData)
		} else {
			print("Error getting contact card for user")
			return ("vcf", NSData())
		}
	}
	
	func communicator(comm: Communicator, didReceiveSharedData data: AnyObject, ofType type: String) {
		if type == "vcf" {
			guard let data = data as? NSData,
				_contacts = try? CNContactVCardSerialization.contactsWithData(data) as? [CNContact],
				contacts = _contacts
			else {
				print("Unable to read VCF data")
				return
			}
			
			// save VCF data
			let store = CNContactStore()
			let saveRequest = CNSaveRequest()
			contacts.forEach { (contact) -> () in
				saveRequest.addContact(contact.mutableCopy() as! CNMutableContact, toContainerWithIdentifier: nil)
			}
			_ = try? store.executeSaveRequest(saveRequest)
		} else if type == "LinkedIn" {
			guard let username = data as? String else {
				print("Unable to read username")
				return
			}
			
			// friend him on LinkedIn
			let profileURL = NSURL(string: "https://linkedin.com/in/" + username)!
			UIApplication.sharedApplication().openURL(profileURL)
		} else {
			print("Unknown type")
		}
	}
}
