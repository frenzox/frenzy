//
//  Parser.swift
//  FrenzyPackageDescription
//
//  Created by Guilherme Felipe da Silva on 05/11/17.
//

import Core
import IO
import Venice
import Foundation

protocol ParserDelegate {
    func didReceiveConnect(_ reader: Parser, client: Client)
    func didReceivePublish(_ reader: Parser, message: Message, id: UInt16)
    func didReceivePubAck(_ reader: Parser, msgid: UInt16)
    func didReceivePubRec(_ reader: Parser, msgid: UInt16)
    func didReceivePubRel(_ reader: Parser, msgid: UInt16)
    func didReceivePubComp(_ reader: Parser, msgid: UInt16)
    func didReceiveSubAck(_ reader: Parser, msgid: UInt16)
    func didReceiveUnsubAck(_ reader: Parser, msgid: UInt16)
    func didReceivePing(_ reader: Parser)
}

class Parser {
    private var stream: DuplexStream!
    private var header: UInt8 = 0
    private var length: UInt = 0
    private var data: [UInt8] = []
    private var multiply = 1
    private var delegate: ParserDelegate
    private var timeout = 30000
    
    init(stream: DuplexStream, delegate: ParserDelegate) {
        self.stream = stream
        self.delegate = delegate
    }
    
    func start() {
        readHeader()
    }
    
    func headerReady(_ header: UInt8) {
        print("reader header ready: \(header) ")
        
        self.header = header
        readLength()
    }
    
    func lengthReady(_ byte: UInt8) {
        length += (UInt)((Int)(byte & 127) * multiply)
        // done
        if byte & 0x80 == 0 {
            if length == 0 {
                frameReady()
            } else {
                readPayload()
            }
            // more
        } else {
            multiply *= 128
            readLength()
        }
    }
    
    func payloadReady(_ data: [UInt8]) {
        self.data = data
        frameReady()
    }
    
    private func readHeader() {
        reset()
        let buffer = UnsafeMutableRawBufferPointer.allocate(count: 1)
        _ = try? self.stream.read(buffer, deadline: Deadline.never)
        headerReady(buffer.load(as: UInt8.self))
    }
    
    private func readLength() {
        let buffer = UnsafeMutableRawBufferPointer.allocate(count: 1)
        _ = try? self.stream.read(buffer, deadline: timeout.milliseconds.fromNow())
        lengthReady(buffer.load(as: UInt8.self))
    }
    
    private func readPayload() {
        let buffer = UnsafeMutableRawBufferPointer.allocate(count: Int(length))
        try? self.stream.read(buffer, deadline: timeout.milliseconds.fromNow())
        payloadReady(Array(buffer))
    }
    
    private func frameReady() {
        let frameType = ControlPacketType(rawValue: UInt8(header & 0xF0))!
        switch frameType {
        case .connect:
            print("CONNECT MSG RECEIVED")
//            let client = self.parseClient()
            delegate.didReceiveConnect(self, client: Client())
        case .publish:
            let (msgid, message) = unpackPublish()
            if message != nil {
                delegate.didReceivePublish(self, message: message!, id: msgid)
            }
        case .puback:
            delegate.didReceivePubAck(self, msgid: msgid(data))
        case .pubrec:
            delegate.didReceivePubRec(self, msgid: msgid(data))
        case .pubrel:
            delegate.didReceivePubRel(self, msgid: msgid(data))
        case .pubcomp:
            delegate.didReceivePubComp(self, msgid: msgid(data))
        case .suback:
            delegate.didReceiveSubAck(self, msgid: msgid(data))
        case .unsuback:
            delegate.didReceiveUnsubAck(self, msgid: msgid(data))
        case .pingresp:
            delegate.didReceivePing(self)
        default:
            break
        }
        readHeader()
    }
    
    private func unpackPublish() -> (UInt16, Message?) {
        let frame = PublishPacket(fixedHeader: header, data: data)
        frame.unpack()
        // if unpack fail
        if frame.msgid == nil {
            return (0, nil)
        }
        let msgid = frame.msgid!
        let qos = QoS(rawValue: frame.qos)!
        let message = Message(topic: frame.topic!, payload: frame.payload, qos: qos, retained: frame.retained, dup: frame.dup)
        return (msgid, message)
    }
    
    private func msgid(_ bytes: [UInt8]) -> UInt16 {
        if bytes.count < 2 { return 0 }
        return UInt16(bytes[0]) << 8 + UInt16(bytes[1])
    }
    
    private func reset() {
        length = 0
        multiply = 1
        header = 0
        data = []
    }
}
