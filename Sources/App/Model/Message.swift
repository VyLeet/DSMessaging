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
    static var listLock = NSLock()
    static var counterLock = NSLock()
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.text = try container.decode(String.self, forKey: .text)
        self.id = (try? container.decode(Int.self, forKey: .id)) ?? (Message.getId() ?? 0).advanced(by: 1)
    }
    
    static private(set) var list = [Message]()
    static private(set) var counter = 0
    
    static func getId() -> Int {
        counterLock.lock()
        counter += 1
        counterLock.unlock()
        return counter
    }

    static func log(_ message: Message) {
        listLock.lock()
        if (list.contains(where: { $0.id == message.id }) == false)
        {
            list.append(message)
            if (list.count >= 2 && (list[list.count-1].id < list[list.count-2].id)) 
            {
                list.sort(by: { $0.id < $1.id })
            }
        }
        listLock.unlock()
    }
}