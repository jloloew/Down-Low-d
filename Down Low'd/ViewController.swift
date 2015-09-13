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
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		nameField.becomeFirstResponder()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
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
}
