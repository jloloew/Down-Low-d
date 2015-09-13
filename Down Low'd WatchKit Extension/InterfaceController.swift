//
//  InterfaceController.swift
//  Down Low'd WatchKit Extension
//
//  Created by Justin Loew on 9/12/15.
//  Copyright © 2015 Justin Loew. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController {
	
	private let numCoinImages = 57
	
	@IBOutlet var downlowdLogo: WKInterfaceImage!
	@IBOutlet var coinImage: WKInterfaceImage!
	@IBOutlet weak var coinPicker: WKInterfacePicker!
	@IBOutlet var contactLabel: WKInterfaceLabel!
	@IBOutlet weak var accelCountLabel: WKInterfaceLabel!
	var accelCount = 0 {
		didSet {
			accelCountLabel?.setText("\(accelCount)")
		}
	}
	let accelDataListener = AccelDataListener()
	private var wcsess: WCSession!
	
	override func willActivate() {
		// This method is called when watch view controller is about to be visible to user
		super.willActivate()
		// set up WCSession
		guard WCSession.isSupported() else {
			fatalError("WCSession not supported")
		}
		wcsess = WCSession.defaultSession()
		wcsess.delegate = self
		wcsess.activateSession()
		// start accelerometer data listener
		accelDataListener.delegate = self
		accelDataListener.start()
		
		// set up picker
		var pickerItems = [WKPickerItem]()
		for i in 1...numCoinImages {
			let pickerItem = WKPickerItem()
			pickerItem.contentImage = WKImage(imageName: "Bubble\(i).png")
			pickerItems.append(pickerItem)
		}
		coinPicker.setItems(pickerItems)
//		coinPicker.setCoordinatedAnimations([coinImage])
		coinPicker.focus()
	}
	
	override func didDeactivate() {
		// This method is called when watch view controller is no longer visible
		super.didDeactivate()
	}
	
	@IBAction func coinPickerChanged(value: Int) {
		// wrap around
		if value == 0 {
			coinPicker.setSelectedItemIndex(numCoinImages - 2)
		} else if value == numCoinImages - 1 {
			coinPicker.setSelectedItemIndex(1)
		}
	}
	
	func sendAccelerationOfMagnitude(mag: Double) {
		guard wcsess.reachable else {
			// TODO: launch iOS app
			return
		}
		
		let message: [String : AnyObject] = [
			"magnitude": mag,
			"timestamp": Int(NSDate.timeIntervalSinceReferenceDate())
			// the iOS app will add the location info
		]
		wcsess.sendMessage(message, replyHandler: nil) { (error) -> Void in
			print(error)
		}
	}
	
}

extension InterfaceController: WCSessionDelegate {
	func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
		print("Received message from phone: \(message)")
	}
}

extension InterfaceController: AccelDataListenerDelegate {
	func accelDataListener(_: AccelDataListener, didFindSpikeOfMagnitude magnitude: Double) {
		accelCount++
		sendAccelerationOfMagnitude(magnitude)
	}
}
