//
//  Client.swift
//  Broker
//
//  Created by Guilherme Felipe da Silva on 17/05/17.
//
//

import Foundation

public enum ConnectionState: UInt8 {
    case initial = 0
    case connecting
    case connected
    case disconnected
}

class Client {
    open var host = "localhost"
    open var port: UInt16 = 1883
    open var clientID: String = ""
    open var username: String?
    open var password: String?
    open var secure = false
    open var cleanSession = true
    open var backgroundOnSocket = false
    open var connState = ConnectionState.initial
    var willMessage: Will?
    open var keepAlive: UInt16 = 60
}
