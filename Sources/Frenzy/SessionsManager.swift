//
//  SessionsManager.swift
//  FrenzyPackageDescription
//
//  Created by Guilherme Felipe da Silva on 05/11/17.
//

import Core
import IO
import Venice
import Foundation

class SessionManager {
    private var sessions: [Session]!
    
    static let shared = SessionManager()
    
    private init() {
        self.sessions = [Session]()
    }
    
    func session(for id: String, stream: DuplexStream) -> Session {
        if let existingSession = self.sessions.filter({ $0.clientId == id }).first {
            existingSession.stream = stream
            return existingSession
        }
        
        let newSession = Session(stream: stream)
        sessions.append(newSession)
        
        return newSession
    }
}
