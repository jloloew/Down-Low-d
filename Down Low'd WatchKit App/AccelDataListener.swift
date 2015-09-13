//
//  AccelDataListener.swift
//  Down Low'd
//
//  Created by Justin Loew on 9/12/15.
//  Copyright © 2015 Justin Loew. All rights reserved.
//

import WatchKit
import CoreMotion

protocol AccelDataListenerDelegate: AnyObject {
	func accelDataListener(listener: AccelDataListener, didFindSpikeOfMagnitude magnitude: Double)
}

class AccelDataListener: AnyObject {
	
	let accelReadDelay: NSTimeInterval = 0.05 // amount of time to wait between each read from accel data
	let threshold = 2.0
	let manager = CMMotionManager()
	weak var delegate: AccelDataListenerDelegate!
	private var paused = true
	private var isSpiking = false // whether the last reading was a spike
	
	init() {
		manager.startAccelerometerUpdates()
	}
	
	deinit {
		manager.stopAccelerometerUpdates()
	}
	
	func start() {
		guard paused else { // don't allow more than one chain of updates to start
			return
		}
		
//		manager.startAccelerometerUpdates()
		paused = false
		print("Starting accel updates \(manager.accelerometerData)")
		handleNewAccelData(manager.accelerometerData!)
	}
	
	func stop() {
		paused = true
		manager.stopAccelerometerUpdates()
		print("Stopping accel updates")
	}
	
	private func handleNewAccelData(data: CMAccelerometerData) {
		// get magnitude
		let data = data.acceleration
		let magnitude = (data.x*data.x) + (data.y*data.y) + (data.z*data.z)
		let userAccel = abs(magnitude - 1.0)
//		print(userAccel)
		
		// filter magnitude
		if userAccel >= self.threshold && !isSpiking { // only process new spikes
			print("Spike detected (\(userAccel)g)")
			self.delegate.accelDataListener(self, didFindSpikeOfMagnitude: userAccel)
			isSpiking = true
		} else {
			isSpiking = false
		}
		
		// schedule recursion if we're not paused
		if !paused {
			dispatch_after(dispatch_time_t(self.accelReadDelay * Double(NSEC_PER_SEC)), dispatch_get_main_queue()) { () -> Void in
				self.handleNewAccelData(self.manager.accelerometerData!)
			}
		}
	}
	
}
