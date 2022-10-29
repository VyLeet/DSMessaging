import Vapor

var messages = [Message]()

enum SecondaryServer: String, CaseIterable {
    case s2 = "http://secondary-app-1:8080"
    case s3 = "http://secondary-app-2:8080"
    
    static var allCases: [SecondaryServer] = [.s2, .s3]
}

func routes(_ app: Application) throws {
    app.get { req async throws in
        try await req.view.render("index", ["title": "Введіть повідомлення:"])
    }
    
    app.get("list") { req async throws in
        try await req.view.render("list", ["messages": messages])
    }
    
    app.post("send") { req async throws -> Response in
        guard let message = try? req.content.decode(Message.self) else {
            return req.redirect(to: "/")
        }
        
        messages.append(message)
        
        Task {
            var acknowledgements = [SecondaryServer: Bool]()
            SecondaryServer.allCases.forEach { acknowledgements[$0] = false }
            
            try _ = await req.client.post(URI(stringLiteral: SecondaryServer.s2.rawValue + "/send"),
                                          content: message)
        }
        
        return req.redirect(to: "list")
    }
}
