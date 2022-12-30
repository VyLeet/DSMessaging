import Leaf
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.views.use(.leaf)
    app.http.server.configuration.port = 8080
    

    // register routes
    try routes(app)
    
    if Environment.isMaster {
        DispatchQueue.global(qos: .background).async {
            beginCheckingHealth()
        }
    }
}
