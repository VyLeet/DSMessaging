//
//  PathParameter.swift
//  
//
//  Created by Nazariy Vysokinskyi on 02.12.2022.
//

import Vapor

enum PathParameter: String {
    case home   = "/"
    case list   = "/list"
    case fail   = "/fail"
    case health = "/health"
    case send   = "/send"
}
