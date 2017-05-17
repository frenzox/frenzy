//
//  MQTTPacket.swift
//  MQTTBroker
//
//  Created by Guilherme Felipe da Silva on 21/04/17.
//
//

enum MQTTControlPacketType: UInt8 {
    case Reserved    = 0x00
    case CONNECT     = 0x10
    case CONNACK     = 0x20
    case PUBLISH     = 0x30
    case PUBACK      = 0x40
    case PUBREC      = 0x50
    case PUBREL      = 0x60
    case PUBCOMP     = 0x70
    case SUBSCRIBE   = 0x80
    case SUBACK      = 0x90
    case UNSUBSCRIBE = 0xA0
    case UNSUBACK    = 0xB0
    case PINGREQ     = 0xC0
    case PINGRESP    = 0xD0
    case DISCONNECT  = 0xE0
}

class MQTTControlPacket {
    var fixedHeader: UInt8 = 0
    
    var type: MQTTControlPacketType {
        return MQTTControlPacketType(rawValue: UInt8(fixedHeader & 0xF0))!
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
    
    var remainingLength: [UInt8] {
        get {
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
    }
    
    init(fixedHeader: UInt8) {
        self.fixedHeader = fixedHeader
    }
    
    init(type: MQTTControlPacketType, payload: [UInt8]) {
        self.fixedHeader = type.rawValue
        self.payload     = payload
    }
}

class MQTTConnectPacket: MQTTControlPacket {
    
}
