//
//  File.swift
//  
//
//  Created by Nazariy Vysokinskyi on 18.11.2022.
//

import Vapor

enum WriteConcern: Int {
    case onlyMaster              = 0
    case masterAndOneSecondary   = 1
    case masterAndTwoSecondaries = 2
    
    func canReturnOK(withStatuses statuses: [MessagingServer: HTTPStatus?]) -> Bool {
        switch self {
            case .onlyMaster:
                return statuses[.master] == .ok
            case .masterAndOneSecondary:
                return statuses[.master] == .ok
                && [statuses[.s2], statuses[.s3]].contains(.ok)
            case .masterAndTwoSecondaries:
                return [statuses[.master], statuses[.s2], statuses[.s3]]
                    .filter { $0 == .ok }
                    .count == 3
        }
    }
}

extension WriteConcern: CaseIterable {
    static var allCases: [WriteConcern] = [.onlyMaster, .masterAndOneSecondary, .masterAndTwoSecondaries]
}
