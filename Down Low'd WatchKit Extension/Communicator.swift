//
//  Communicator.swift
//  Down Low'd
//
//  Created by Justin Loew on 9/12/15.
//  Copyright © 2015 Justin Loew. All rights reserved.
//

import WatchKit

private let _server = "localhost"
private let _port = 8888

protocol CommunicatorDelegate: AnyObject {
	func communicatorGetDataForSharing(comm: Communicator) -> (type: String, data: AnyObject)
	func communicator(comm: Communicator, didReceiveSharedData data: NSData)
}

class Communicator: NSObject {
	
	var server: String { return _server }
	var port: Int { return _port }
	var host: String { return "\(server):\(port)" }
	let socket = SocketIOClient(socketURL: "\(_server):\(_port)")
	weak var delegate: CommunicatorDelegate!
	
	override init() {
		super.init()
		
		setUpSocketHandlers()
		socket.connect()
	}
	
	private func setUpSocketHandlers() {
		socket.on("connect") { (_, _) -> Void in
			print("socket connected")
		}
		
		socket.on("matchFoundShouldUploadData") { (_, _) -> Void in
			print("matchFoundShouldUploadData")
			let (type, data) = self.delegate.communicatorGetDataForSharing(self)
			self.socket.emit("shareData", withItems: [[
				"type": type,
				"data": data
			]])
		}
		
	}
	
	func sendDict(dict: [String : AnyObject]) {
		socket.emit("accelerationDetected", withItems: [dict])
	}
}
