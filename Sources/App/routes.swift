import Vapor

func routes(_ app: Application) throws {
    app.get { req async throws -> Response in
        if Environment.isMaster {
            return try await req.view.render("index").encodeResponse(for: req)
        } else {
            return req.redirect(to: "/list")
        }
    }
    
    app.get("list") { req async throws in
        try await req.view.render("list", ["messages": Message.log])
    }
    
    app.post("send") { req async throws -> Response in
        guard let message = try? req.content.decode(Message.self),
              !message.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !Message.log.contains(where: { $0.id == message.id })
        else {
            return req.redirect(to: "/")
        }
        
        Message.log.append(message)
        
        if Environment.isMaster {
            var statuses: [MessagingServer: HTTPStatus?] = [
                .master: .ok
            ]
            
            var canReturnOK = false
            
            try? await withThrowingTaskGroup(of: (server: MessagingServer, status: HTTPStatus).self) { group in
                for secondaryServer in MessagingServer.secondaryServers {
                    group.addTask {
                        let uri = URI(stringLiteral: secondaryServer.urlString + "/send")
                        let clientResponse = try? await req.client.post(uri, content: message)
                        return (secondaryServer, clientResponse?.status ?? .requestTimeout)
                    }
                }
                
                for try await entry in group {
                    statuses[entry.server] = entry.status
                    
                    if Environment.writeConcern.canReturnOK(withStatuses: statuses) {
                        canReturnOK = true
                        group.cancelAll()
                        break
                    }
                }
            }
            
            return canReturnOK ? req.redirect(to: "/list") : req.redirect(to: "/fail")
        } else {
            do {
                sleep(1)
                
                return req.redirect(to: "/list")
            }
        }
    }
}
