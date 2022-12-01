//
//  Message.swift
//  
//
//  Created by Nazariy Vysokinskyi on 01.10.2022.
//

import Vapor

struct Message: Content, Identifiable {
    let text: String
    var id: Int
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.text = try container.decode(String.self, forKey: .text)
        self.id = (try? container.decode(Int.self, forKey: .id)) ?? Self.generateID()
    }
}

extension Message {
    static var listLock = NSLock()
    static var counterLock = NSLock()
    
    static private(set) var list = [Message]()
    static private var counter = 0
    
    static private func generateID() -> Int {
        self.counterLock.lock()
        defer { self.counterLock.unlock() }
        
        self.counter += 1
        return counter
    }

    static func log(_ message: Message) {
        self.listLock.lock()
        defer { self.listLock.unlock() }
        
        guard false == self.list.contains(where: { $0.id == message.id }) else {
            return
        }
        
        self.list.append(message)
        
        if self.list.count >= 2 && self.list[list.count - 1].id < self.list[list.count - 2].id {
            self.list.sort { $0.id < $1.id }
        }
    }
}
