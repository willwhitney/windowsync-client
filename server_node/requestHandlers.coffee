fs = require 'fs'
redis = require "redis"
redclient = redis.createClient()
WINDOWID = 000000

redclient.on("error", (err) ->
    console.log "redis error: " + err
)

start = (response) ->    
    

    fs.readFile('index.html', (err, data) ->
        if (err) 
            response.writeHead(500)
            return res.end('Error loading index.html')
        
        response.writeHead(200)
        response.end(data)
    )

        
exports.start = start

