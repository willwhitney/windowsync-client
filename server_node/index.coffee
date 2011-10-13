server = require "./server"
router = require "./router"
requestHandlers = require "./requestHandlers"

handle = {}
handle["/"] = requestHandlers.start
handle["/start"] = requestHandlers.start
handle["/socket"] = requestHandlers.socket

server.start(router.route, handle)