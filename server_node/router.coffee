route = (handle, pathname, response) ->
    console.log "routing a request for #{pathname}"
    if typeof handle[pathname] == 'function'
        handle[pathname](response)
    else
        console.log "no handle for #{pathname}"
        response.writeHead(404, {"Content-Type": "text/plain"})
        response.write "404 Not found"
        response.end()    
        
exports.route = route