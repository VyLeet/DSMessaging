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
        self.id = (try? container.decode(Int.self, forKey: .id)) ?? (Self.log.last?.id ?? 0).advanced(by: 1)
    }
    
    static var log = [Message]()
}
