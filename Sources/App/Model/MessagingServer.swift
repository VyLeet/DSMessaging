//
//  MessagingServer.swift
//  
//
//  Created by Nazariy Vysokinskyi on 30.10.2022.
//

import Foundation

enum MessagingServer: Int {
    case master = 0
    case s2 = 1
    case s3 = 2
    
    var urlString: String { "http://secondary-app-\(self.rawValue):8080" }
    
    static let secondaryServers: [MessagingServer] = [.s2, .s3]
    static let maxRetries: 13
}

extension MessagingServer: CaseIterable {
    static var allCases: [MessagingServer] = [.master, .s2, .s3]
}
