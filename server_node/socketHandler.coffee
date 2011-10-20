redis = require "redis"
redclient = redis.createClient()

redclient.on("error", (err) ->
    console.log "redis error: " + err
    )

handleSocket = (socket) ->
    socket.emit('tabAdded', {'index': 0, 'url':"http://google.com/"})
    
    # socket.emit('news', { hello: 'world' })
        
    socket.on('tabAdded', (tab) ->
        
        console.log "tab added:"
        console.log tab
        socket.broadcast.emit('tabAdded', tab)
        
        id = tab['id']
        redclient.set(id, tab, redis.print)
        
        socket.emit('tabId', {clientId: tab['id'], serverId: id })
        
        # for key of data
        #     redclient.set(key, data[key], redis.print)
        # for key of data
        #     redclient.get(key, redis.print)
    )
    
    socket.on('tabRemoved', (tab) ->
        console.log "tab removed:"
        console.log tab
        socket.broadcast.emit('tabRemoved', tab)
        redclient.del(tab['id'], redis.print)
    )
    
    socket.on('tabUpdated', (tab) ->
        console.log "tab updated:"
        console.log tab
        socket.broadcast.emit('tabUpdated', tab)
        redclient.set(tab['id'], tab, redis.print)
    )
    
    socket.on('tabMoved', (tab) ->
        console.log "tab moved:"
        console.log tab
    )
    
    
    
exports.handleSocket = handleSocket