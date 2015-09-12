//
//  InterfaceController.swift
//  Down Low'd WatchKit Extension
//
//  Created by Justin Loew on 9/12/15.
//  Copyright © 2015 Justin Loew. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
	
	@IBOutlet weak var accelCountLabel: WKInterfaceLabel!
	var accelCount = 0 {
		didSet {
			accelCountLabel?.setText("\(accelCount)")
		}
	}
	var accelDataListener: AccelDataListener!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
		
		accelDataListener = AccelDataListener(spikeDetectedHandler: { () -> Void in
			self.accelCount++
		})
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
		accelDataListener = nil
        super.didDeactivate()
    }

}
