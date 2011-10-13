http = require "http"
url = require "url"
socketio = require("socket.io")

start = (route, handle) ->
    onRequest = (request, response) ->
        pathname = url.parse(request.url).pathname
        console.log "request for #{pathname} received."
        
        route(handle, pathname, response)
        
    app = http.createServer(onRequest)
    io = socketio.listen(app)
    app.listen(8888)
    console.log "server started"
    
    io.sockets.on('connection', (socket) ->
        socket.emit('news', {hello: 'world'})
        socket.on('other event', (data) ->
            console.log(data)
        )
    )
    
exports.start = start
