//
//  File.swift
//  
//
//  Created by Nazariy Vysokinskyi on 30.10.2022.
//

import Vapor

extension Environment {
    static var isMaster = Environment.get("ROLE") == "master"
    
    static let writeConcern = WriteConcern.allCases.randomElement()!
}
