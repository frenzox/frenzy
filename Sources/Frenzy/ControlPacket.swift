//
//  Packet.swift
//  Fernzy
//
//  Created by Guilherme Felipe da Silva on 21/04/17.
//
//

import Foundation

enum ControlPacketType: UInt8 {
    case reserved    = 0x00
    case connect     = 0x10
    case connack     = 0x20
    case publish     = 0x30
    case puback      = 0x40
    case pubrec      = 0x50
    case pubrel      = 0x60
    case pubcomp     = 0x70
    case subscribe   = 0x80
    case suback      = 0x90
    case unsubscribe = 0xA0
    case unsuback    = 0xB0
    case pingreq     = 0xC0
    case pingresp    = 0xD0
    case disconnect  = 0xE0
}

class ControlPacket {
    var fixedHeader: UInt8 = 0
    
    var type: ControlPacketType {
        return ControlPacketType(rawValue: UInt8(fixedHeader & 0xF0))!
    }
    
    var dup: Bool {
        get {
            return ((fixedHeader & 0x08) >> 3) == 0 ? false : true
        }
        set {
            fixedHeader |= ((newValue ? 0x01 : 0x00) << 3)
        }
    }
    
    var qos: UInt8 {
        get {
            return ((fixedHeader & 0x06) >> 1)
        }
        set {
            fixedHeader |= (newValue << 1)
        }
    }
    
    var retained: Bool {
        get {
            return (fixedHeader & 0x01) == 0 ? false : true
        }
        set {
            fixedHeader |= (newValue ? 0x01 : 0x00)
        }
    }
    
    var variableHeader: [UInt8] = []
    var payload:        [UInt8] = []
    
    func encodeLength() -> [UInt8] {
        var bytes: [UInt8] = []
        var digit: UInt8 = 0
        var len: UInt32 = UInt32(variableHeader.count + payload.count)
        
        repeat {
            digit = UInt8(len % 128)
            len = len / 128
            
            if len > 0 {
                digit = digit | 0x80
            }
            
            bytes.append(digit)
        } while(len > 0)
        
        return bytes
    }
    
    init(type: ControlPacketType, payload: [UInt8] = []) {
        self.fixedHeader = type.rawValue
        self.payload     = payload
    }
    
    init(fixedHeader: UInt8) {
        self.fixedHeader = fixedHeader
    }
    
    func pack() {}
    
    func readLengthPrefixedField(buf: [UInt8]) -> [UInt8]? {
        if buf.count < 2 {
            return nil
        }
        
        var total:UInt16 = 0
        
        let n = UInt16.init(bigEndian: UInt16(buf[0] << 8 + buf[1]))
        total += 2
        
        if buf.count - Int(total) < n {
            return nil
        }
        
        total += n
        
        return Array(buf[2...Int(total)])
    }
}

class ConnectPacket: ControlPacket {
    
    let PROTOCOL_LEVEL = UInt8(4)
    let PROTOCOL_VERSION: String  = "/3.1.1"
    let PROTOCOL_MAGIC: String = ""
    
    /**
     * |----------------------------------------------------------------------------------
     * |     7    |    6     |      5     |  4   3  |     2    |       1      |     0    |
     * | username | password | willretain | willqos | willflag | cleansession | reserved |
     * |----------------------------------------------------------------------------------
     */
    var flags: UInt8 = 0
    
    var flagUsername: Bool {
        // #define FLAG_USERNAME(F, U)		(F | ((U) << 7))
        get {
            return Bool(bit: (flags >> 7) & 0x01)
        }
        
        set {
            flags |= (newValue.bit << 7)
        }
    }
    
    var flagPassword: Bool {
        // #define FLAG_PASSWD(F, P)		(F | ((P) << 6))
        get {
            return Bool(bit:(flags >> 6) & 0x01)
        }
        
        set {
            flags |= (newValue.bit << 6)
        }
    }
    
    var flagWillRetain: Bool {
        // #define FLAG_WILLRETAIN(F, R) 	(F | ((R) << 5))
        get {
            return Bool(bit: (flags >> 5) & 0x01)
        }
        
        set {
            flags |= (newValue.bit << 5)
        }
    }
    
    var flagWillQOS: UInt8 {
        // #define FLAG_WILLQOS(F, Q)		(F | ((Q) << 3))
        get {
            return (flags >> 3) & 0x03
        }
        
        set {
            flags |= (newValue << 3)
        }
    }
    
    var flagWill: Bool {
        // #define FLAG_WILL(F, W)			(F | ((W) << 2))
        get {
            return Bool(bit:(flags >> 2) & 0x01)
        }
        
        set {
            flags |= ((newValue.bit) << 2)
        }
    }
    
    var flagCleanSession: Bool {
        // #define FLAG_CLEANSESS(F, C)	(F | ((C) << 1))
        get {
            return Bool(bit: (flags >> 1) & 0x01)
        }
        
        set {
            flags |= ((newValue.bit) << 1)
        }
    }
    
    var data: [UInt8]?
    var client: Client?
    
    init(fixedHeader: UInt8, data: [UInt8]) {
        super.init(fixedHeader: fixedHeader)
        self.data = data
    }
    
    init(client: Client) {
        self.client = client
        super.init(type: .connect)
    }
    
    override func pack() {
        if let client = self.client {
            // variable header
            variableHeader += PROTOCOL_MAGIC.bytesWithLength
            variableHeader.append(PROTOCOL_LEVEL)
            
            // payload
            payload += client.clientID.bytesWithLength
            if let will = client.willMessage {
                flagWill = true
                flagWillQOS = will.qos.rawValue
                flagWillRetain = will.retained
                payload += will.topic.bytesWithLength
                payload += will.payload
            }
            if let username = client.username {
                flagUsername = true
                payload += username.bytesWithLength
            }
            if let password = client.password {
                flagPassword = true
                payload += password.bytesWithLength
            }
            
            // flags
            flagCleanSession = client.cleanSession
            variableHeader.append(flags)
            variableHeader += client.keepAlive.hlBytes
        }
    }
    
    func unpack() {
    }
}

class PublishPacket: ControlPacket {
    var msgid: UInt16?
    var topic: String?
    var data: [UInt8]?
    
    init(msgid: UInt16, topic: String, payload: [UInt8]) {
        super.init(type: ControlPacketType.publish, payload: payload)
        self.msgid = msgid
        self.topic = topic
    }
    
    init(fixedHeader: UInt8, data: [UInt8]) {
        super.init(fixedHeader: fixedHeader)
        self.data = data
    }
    
    func unpack() {
        // topic
        if data!.count < 2 {
            print("Invalid format of rescived message.")
            return
        }
        var msb = data![0]
        var lsb = data![1]
        let len = UInt16(msb) << 8 + UInt16(lsb)
        var pos = 2 + Int(len)
        
        if data!.count < pos {
            print("Invalid format of rescived message.")
            return
        }
        
        topic = NSString(bytes: [UInt8](data![2...(pos-1)]), length: Int(len), encoding: String.Encoding.utf8.rawValue) as String?
        // msgid
        if qos == 0 {
            msgid = 0
        } else {
            if data!.count < pos + 2 {
                print("Invalid format of rescived message.")
                return
            }
            msb = data![pos]
            lsb = data![pos+1]
            pos += 2
            msgid = UInt16(msb) << 8 + UInt16(lsb)
        }
        
        // payload
        let end = data!.count - 1
        
        if (end - pos >= 0) {
            payload = [UInt8](data![pos...end])
            // receives an empty message
        } else {
            payload = []
        }
    }
    
    override func pack() {
        variableHeader += topic!.bytesWithLength
        if qos > 0 {
            variableHeader += msgid!.hlBytes
        }
    }
}
/**
 * Encode and Decode big-endian UInt16
 */
extension UInt16 {
    // Most Significant Byte (MSB)
    private var highByte: UInt8 {
        return UInt8( (self & 0xFF00) >> 8)
    }
    // Least Significant Byte (LSB)
    private var lowByte: UInt8 {
        return UInt8(self & 0x00FF)
    }
    
    fileprivate var hlBytes: [UInt8] {
        return [highByte, lowByte]
    }
}

/**
 * String with two bytes length
 */
extension String {
    // ok?
    var bytesWithLength: [UInt8] {
        return UInt16(utf8.count).hlBytes + utf8
    }
}

/**
 * Bool to bit
 */
extension Bool {
    fileprivate var bit: UInt8 {
        return self ? 1 : 0
    }
    
    fileprivate init(bit: UInt8) {
        self = (bit == 0) ? false : true
    }
}

/**
 * read bit
 */
extension UInt8 {
    fileprivate func bitAt(_ offset: UInt8) -> UInt8 {
        return (self >> offset) & 0x01
    }
}
