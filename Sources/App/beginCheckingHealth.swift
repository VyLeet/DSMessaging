//
//  beginCheckingHealth.swift
//  
//
//  Created by Nazariy Vysokinskyi on 30.12.2022.
//

import Foundation
import Vapor

func beginCheckingHealth() {
    let keyValuePairs = MessagingServer.secondaryServers.map { ($0.rawValue, 0)}
    var consecutiveHealthCheckFails = Dictionary(uniqueKeysWithValues: keyValuePairs)
    var lastCheckSecond = 0
    
    while true {
        let currentSecond = Calendar.current.component(.second, from: Date())
        
        if currentSecond % 10 == 1 && currentSecond != lastCheckSecond {
            lastCheckSecond = currentSecond
            
            for secondaryServer in MessagingServer.secondaryServers {
                Task.detached(priority: .background) {
                    guard let url = URL(string: secondaryServer.urlString + PathParameter.health.rawValue) else { return }
                    let request = URLRequest(url: url)
                    
                    let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
                        guard let response = response as? HTTPURLResponse else { return }
                        let failAdvance = response.statusCode == 200 ? 0 : 1
                        
                        consecutiveHealthCheckFails[secondaryServer.rawValue, default: 0] += failAdvance
                    }
                    task.resume()
                }
            }
        }
    }
}
