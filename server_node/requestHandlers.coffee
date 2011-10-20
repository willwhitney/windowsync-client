fs = require 'fs'

start = (response) ->
    fs.readFile('index.html', (err, data) ->
        if (err) 
            response.writeHead(500)
            return res.end('Error loading index.html')
        
        response.writeHead(200)
        response.end(data)
    )
        
exports.start = start

