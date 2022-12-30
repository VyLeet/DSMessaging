import Vapor

func routes(_ app: Application) throws {
    app.get { req async throws -> Response in
        if Environment.isMaster {
            return try await req.view.render("index").encodeResponse(for: req)
        } else {
            return req.redirect(to: PathParameter.list.rawValue)
        }
    }
    
    app.get("list") { req async throws -> View in
        if Environment.isMaster {
            return try await req.view.render("list", ["messages": Message.list])
        } else {
            let messages = Message.list
            var response = [Message]()
            var lastMessageId = 0
            for message in messages {
                if message.id - lastMessageId < 2 {
                    response.append(message)
                    lastMessageId = message.id
                } else {
                    break
                }
            }
            return try await req.view.render("list", ["messages": response])
        }

    }
    
    app.get("health") { req async throws -> Response in
        return Response(status: .ok)
    }
    
    app.post("send") { req async throws -> Response in
        guard let message = try? req.content.decode(Message.self) else {
            return req.redirect(to: PathParameter.home.rawValue)
        }
        
        if Environment.isMaster {
            guard let concernNumber = req.query[Int.self, at: "writeconcern"],
                  let writeConcern = WriteConcern(rawValue: concernNumber)
            else {
                return req.redirect(to: PathParameter.home.rawValue)
            }
            
            do {
                try Message.log(message)
            } catch {
                return req.redirect(to: PathParameter.home.rawValue)
            }
            
            var statuses: [MessagingServer: HTTPStatus?] = [
                .master: .ok
            ]
            
            var canReturnOK = false
            
            try? await withThrowingTaskGroup(of: (server: MessagingServer, status: HTTPStatus).self) { group in
                for secondaryServer in MessagingServer.secondaryServers {
                    group.addTask {
                        let uri = URI(stringLiteral: secondaryServer.urlString + PathParameter.send.rawValue)
                        var retries = 0
                        var clientResponse: ClientResponse?
                        repeat {
                            clientResponse = try? await req.client.post(uri, content: message)
                            sleep(UInt32(pow(Double(2), Double(retries))))
                            retries += 1
                        } while clientResponse?.status != .ok && clientResponse?.status != .conflict && retries <= MessagingServer.maxRetries
                        return (secondaryServer, clientResponse?.status ?? .requestTimeout)
                    }
                }
                
                for try await entry in group {
                    statuses[entry.server] = entry.status
                    
                    if writeConcern.canReturnOK(withStatuses: statuses) {
                        canReturnOK = true
                        group.cancelAll()
                        break
                    }
                }
            }
            
            return req.redirect(to: (canReturnOK ? PathParameter.list : .fail).rawValue)
        } else {
            do {
                sleep(.random(in: 1...15))
                if .random(in: 1...10) == 1 {
                    throw ErrorMock.randomError
                }
                
                do {
                    try Message.log(message)
                    return Response(status: .ok)
                } catch LoggingError.alreadyLogged {
                    return Response(status: .conflict)
                } catch {
                    return Response(status: .preconditionFailed)
                }
            }
        }
    }
}
