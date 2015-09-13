//
//  ViewController.swift
//  Down Low'd
//
//  Created by Justin Loew on 9/12/15.
//  Copyright © 2015 Justin Loew. All rights reserved.
//

import UIKit
import WatchConnectivity

class ViewController: UIViewController {
	
	@IBOutlet weak var nameField: UITextField!
	@IBOutlet weak var savedLabel: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		nameField.becomeFirstResponder()
		savedLabel.alpha = 0
	}
	
	@IBAction func sendFakeAccel() {
		print("Sending fake accel data")
		let message: [String : AnyObject] = [
			"magnitude": 0.2,
			"timestamp": Int(NSDate.timeIntervalSinceReferenceDate())
//			"location": [
//				"lat": 42.275555556,
//				"lon": -83.731388889
//			]
		]
		
		let ad = (UIApplication.sharedApplication().delegate as! AppDelegate)
		ad.session(WCSession.defaultSession(), didReceiveMessage: message)
	}
	
	func didSaveContact() {
		// delay, then clear
		let labelHoverTime = 4.0
		UIView.animateWithDuration(NSTimeInterval((labelHoverTime-2)/2), delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
			self.savedLabel.alpha = 1
		}, completion: { (_) -> Void in
			UIView.animateWithDuration(NSTimeInterval((labelHoverTime-2)/2), delay: 2.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
				self.savedLabel.alpha = 0
			}, completion: nil)
		})
	}
}
