http = require 'http'
net = require 'net'
io = require('socket.io').listen(1337)
redis = require "redis" 
client = redis.createClient()




client.on("error", (err) -> 
    console.log "Error " + err
)

# client.set("string key", "string val", redis.print)
# client.get("string key", redis.print)

# http.createServer( (req, res) -> 
# 	res.writeHead(200, {'Content-Type': 'text/plain'})
# 	client.get("string key", (error, result) -> 
# 		res.write(result) + "\n"
# 		res.end "done"
# 	)
	
# ).listen(1337, "127.0.0.1")

# net.createServer( (socket) ->
# 	client.get("string key", (error, result) -> 
# 		socket.write(result + "\n")
# 	)
# ).listen(1337, "127.0.0.1")

io.sockets.on('connection', (socket) -> 
	socket.emit('news', "marco")
	socket.on('my other event', (data) -> 
		console.log(data)
	)
)

console.log 'Server running'