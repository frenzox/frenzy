//
//  Message.swift
//  Broker
//
//  Created by Guilherme Felipe da Silva on 17/05/17.
//
//


public enum QoS: UInt8 {
    case qos0
    case qos1
    case qos2
}

/**
 *  Message
 */
open class Message {
    var qos = QoS.qos1
    var dup = false
    
    open var topic: String
    open var payload: [UInt8]
    open var retained = false
    
    // utf8 bytes array to string
    public var string: String? {
        get {
            return String(cString: UnsafePointer(payload))
        }
    }
    
    public init(topic: String, string: String, qos: QoS = .qos1, retained: Bool = false, dup: Bool = false) {
        self.topic = topic
        self.payload = [UInt8](string.utf8)
        self.qos = qos
        self.retained = retained
        self.dup = dup
    }
    
    public init(topic: String, payload: [UInt8], qos: QoS = .qos1, retained: Bool = false, dup: Bool = false) {
        self.topic = topic
        self.payload = payload
        self.qos = qos
        self.retained = retained
        self.dup = dup
    }
}

/**
 *  Will Message
 */
open class Will: Message {
    public init(topic: String, message: String) {
        super.init(topic: topic, payload: message.bytesWithLength)
    }
}
