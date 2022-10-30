//
//  SecondaryServer.swift
//  
//
//  Created by Nazariy Vysokinskyi on 30.10.2022.
//

import Foundation


enum SecondaryServer: Int, CaseIterable {
    case s2 = 1
    case s3
    case s4
    
    var urlString: String { "http://secondary-app-\(self.rawValue):8080" }
    
    static var allCases: [SecondaryServer] = [.s2, .s3, .s4]
}
