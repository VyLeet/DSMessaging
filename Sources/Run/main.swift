import App
import Vapor

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let app = Application(env)
let isMaster = Environment.get("ROLE") == "master"
print("Майстр: \(isMaster ? "✅" : "❌")")
defer { app.shutdown() }
try configure(app)
try app.run()
