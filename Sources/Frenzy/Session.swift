//
//  Session.swift
//  FrenzyPackageDescription
//
//  Created by Guilherme Felipe da Silva on 05/11/17.
//

import Core
import IO
import Venice

public enum SessionState: UInt8 {
    case initializing = 0
    case running
    case finished
}

open class Session: ParserDelegate {
    var clientId: String!
    var client: Client!
    var parser: Parser!
    var stream: DuplexStream!
    
    init(stream: DuplexStream) {
        self.parser = Parser(stream: stream, delegate: self)
        self.parser.start()
    }
    
    func didReceiveConnect(_ reader: Parser, client: Client) {
        self.client = client
    }
    
    func didReceivePublish(_ reader: Parser, message: Message, id: UInt16) {}
    func didReceivePubAck(_ reader: Parser, msgid: UInt16) {}
    func didReceivePubRec(_ reader: Parser, msgid: UInt16) {}
    func didReceivePubRel(_ reader: Parser, msgid: UInt16) {}
    func didReceivePubComp(_ reader: Parser, msgid: UInt16) {}
    func didReceiveSubAck(_ reader: Parser, msgid: UInt16) {}
    func didReceiveUnsubAck(_ reader: Parser, msgid: UInt16) {}
    func didReceivePing(_ reader: Parser) {}
}
