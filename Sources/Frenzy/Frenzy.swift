//
//  Frenzy.swift
//  Frenzy
//
//  Created by Guilherme Felipe da Silva on 17/05/17.
//
//

import Core
import IO
import Venice

public final class Frenzy {
    
    private let group = Coroutine.Group()
    
    private var authenticationHandler: ((_ username: String, _ password: String) -> Bool)?
    private var publishAuthorizationHandler: ((_ username: String, _ topic: String) -> Bool)?
    private var subscribeAuthorizationHandler: ((_ username: String, _ topic: String) -> Bool)?
    
    public func start(host: String = "0.0.0.0", port: Int = 1883) throws {
        let tcp = try TCPHost(host: host, port: port)
        try self.start(host: tcp)
    }
    
    public func start(host: TCPHost) throws {
        while true {
            do {
                Logger.info("Accepting requests")
                try self.accept(host)
            } catch VeniceError.canceledCoroutine {
                Logger.debug("Canceled coroutine")
                break
            } catch {
                Logger.error("Error while accepting connections.", error: error)
                throw error
            }
        }
    }
    
    public func stop() throws {
        Logger.info("Stopping MQTT Broker")
        self.group.cancel()
    }
    
    private func accept(_ host: Host) throws {
        let stream = try host.accept(deadline: .never)
        
        try self.group.addCoroutine {
            self.handleConnection(stream)
        }
    }
}

extension Frenzy {
    private func handleConnection(_ stream: DuplexStream) {
        let buffer = UnsafeMutableRawBufferPointer.allocate(count: 4096)
        while true {
            do {
                _ = try stream.read(buffer, deadline: Deadline.never)
                _ = try stream.write(UnsafeRawBufferPointer.init(buffer), deadline: Deadline.never)
                
                let str = String(buffer)
                print(str)
                
            } catch {
                Logger.error("FODASE")
            }
        }
    }
}
