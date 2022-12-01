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
        self.id = (try? container.decode(Int.self, forKey: .id)) ?? 1
    }
    
    static private(set) var list = [Message]()
    
    static func log(_ message: Message) {
        list.append(message)
    }
}
