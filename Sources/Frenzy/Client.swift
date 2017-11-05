//
//  Client.swift
//  Frenzy
//
//  Created by Guilherme Felipe da Silva on 17/05/17.
//
//

import Foundation

class Client {
    open var host = "localhost"
    open var port: UInt16 = 1883
    open var clientID: String = ""
    open var username: String?
    open var password: String?
    open var secure = false
    open var cleanSession = true
    var willMessage: Message?
    open var keepAlive: UInt16 = 60
}
