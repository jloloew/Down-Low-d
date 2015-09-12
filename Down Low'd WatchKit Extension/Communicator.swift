//
//  Communicator.swift
//  Down Low'd
//
//  Created by Justin Loew on 9/12/15.
//  Copyright © 2015 Justin Loew. All rights reserved.
//

import WatchKit

private let _server = "104.236.59.44"
private let _port = 8080

protocol CommunicatorDelegate: AnyObject {
	func communicatorGetDataForSharing(comm: Communicator) -> (type: String, data: AnyObject)
	// data is either String or NSData
	func communicator(comm: Communicator, didReceiveSharedData data: AnyObject, ofType type: String)
}

class Communicator: NSObject {
	
	var server: String { return _server }
	var port: Int { return _port }
	var host: String { return "\(server):\(port)" }
	let socket = SocketIOClient(socketURL: "\(_server):\(_port)", opts: ["forceWebsockets": true])
	weak var delegate: CommunicatorDelegate!
	private var didSendData = false
	private var didReceiveData = false
	
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
			// close socket if necessary
			self.didSendData = true
			self.waitAndCloseSocket()
		}
		
		socket.on("sharedData") { (data, _) -> Void in
			print("sharedData")
			// close socket if necessary
			self.didReceiveData = true
			self.waitAndCloseSocket()
			
			if let dict = data?[0] as? [String : AnyObject],
				data = dict["data"],
				type = dict["type"] as? String
			{
				self.delegate.communicator(self, didReceiveSharedData: data, ofType: type)
			} else {
				print("Unable to read sharedData")
			}
		}
		
		socket.onAny { (anyEvent) -> Void in
			print("Received any: " + anyEvent.event)
		}
		
		socket.on("error") { (data, _) -> Void in
			print("Error: \(data ?? nil)")
		}
	}
	
	func waitAndCloseSocket() {
		// only close if we're done trading info or we haven't started yet
		if didSendData != didReceiveData {
			socket.close(fast: false)
		}
	}
	
	func sendDict(dict: [String : AnyObject]) {
		print("Sending dict: \(dict)")
		socket.emit("accelerationDetected", withItems: [dict])
	}
}
