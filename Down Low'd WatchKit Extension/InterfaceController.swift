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
	
	@IBOutlet weak var accelCountLabel: WKInterfaceLabel!
	var accelCount = 0 {
		didSet {
			accelCountLabel?.setText("\(accelCount)")
		}
	}
	var accelDataListener: AccelDataListener!
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
		accelDataListener = AccelDataListener(spikeDetectedHandler: { (magnitude) -> Void in
			self.accelCount++
			self.sendAccelerationOfMagnitude(magnitude)
		})
	}
	
	override func didDeactivate() {
		// This method is called when watch view controller is no longer visible
		accelDataListener = nil
		super.didDeactivate()
	}
	
	func sendAccelerationOfMagnitude(mag: Double) {
		guard wcsess.reachable else {
			// TODO: launch iOS app
			return
		}
		
		let message = [
			"magnitude": mag,
			"timestamp": NSDate()
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
