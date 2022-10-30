import Vapor

func routes(_ app: Application) throws {
    app.get { req async throws in
        try await req.view.render("index")
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
            Task {
                for secondaryServer in SecondaryServer.allCases {
                    let uri = URI(stringLiteral: secondaryServer.urlString + "/send")
                    let clientResponse = try await req.client.post(uri, content: message)
                    if clientResponse.status != .ok {
                        sleep(UInt32.max)
                    }
                }
            }
        } else {
            do {
                sleep(1)
            }
        }
        
        return req.redirect(to: "/list")
    }
}
