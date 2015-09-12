//
//  AccelDataListener.swift
//  Down Low'd
//
//  Created by Justin Loew on 9/12/15.
//  Copyright © 2015 Justin Loew. All rights reserved.
//

import WatchKit
import CoreMotion

class AccelDataListener: NSObject {
	
	let threshold = 0.2
	let callbackPauseTime: NSTimeInterval = 1.0
	let manager = CMMotionManager()
	private var handler: CMAccelerometerHandler!
	
	init(spikeDetectedHandler: (magnitude: Double) -> Void) {
		super.init()
		manager.accelerometerUpdateInterval = 0.01
		handler = { (data, error) -> Void in
			guard let data = data?.acceleration else {
				print(error)
				return
			}
			
			let magnitude = data.x*data.x + data.y*data.y + data.z*data.z
			let userAccel = abs(magnitude - 1.0)
			// filter magnitude
			if userAccel >= self.threshold {
				print("Spike detected (\(userAccel)g)")
				spikeDetectedHandler(magnitude: userAccel)
				// pause callbacks
				print("pausing accel triggers for \(self.callbackPauseTime) seconds")
				self.manager.stopAccelerometerUpdates()
				dispatch_after(dispatch_time_t(self.callbackPauseTime * Double(NSEC_PER_SEC)), dispatch_get_main_queue()) { () -> Void in
					print("resuming accel triggers")
					self.manager.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: self.handler)
				}
			}
		}
		print("starting accel triggers")
		manager.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: handler)
	}
	
	deinit {
		manager.stopAccelerometerUpdates()
	}
	
//	func start() {
//		manager.startAccelerometerUpdates()
//	}
//	
//	func stop() {
//		manager.stopAccelerometerUpdates()
//	}
	
}
