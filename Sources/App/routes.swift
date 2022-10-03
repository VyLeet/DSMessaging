import Vapor

var messages = [Message]()

enum SecondaryServer: String, CaseIterable {
    case s2 = "http://127.0.0.1:8081"
    case s3 = "http://127.0.0.1:8082"
    
    static var allCases: [SecondaryServer] = [.s2, .s3]
}

func routes(_ app: Application) throws {
    app.get { req async throws in
        try await req.view.render("index", ["title": "Введіть повідомлення:"])
    }
    
    app.get("list") { req async throws in
        try await req.view.render("list", ["messages": messages])
    }
    
    app.post("send") { req async throws in
        guard let message = try? req.content.decode(Message.self) else {
            return req.redirect(to: "/")
        }
        
        messages.append(message)
        
        try await _ = req.client.post(URI(stringLiteral: SecondaryServer.s2.rawValue + "/send"),
                                      content: message)
        
        return req.redirect(to: "list")
    }
}
