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
            for secondaryServer in SecondaryServer.allCases {
                let uri = URI(stringLiteral: secondaryServer.urlString + "/send")
                let clientResponse = try await req.client.post(uri, content: message)
                if clientResponse.status != .ok {
                    return req.redirect(to: "/fail")
                }
            }
            
            return req.redirect(to: "/list")
            
        } else {
            do {
                sleep(3)
                
                return req.redirect(to: "/list")
            }
        }
    }
}
