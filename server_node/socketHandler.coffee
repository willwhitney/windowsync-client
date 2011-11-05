redis = require "redis"
redclient = redis.createClient()
WINDOWID = 000000

redclient.on("error", (err) ->
    console.log "redis error: " + err
)



# redclient.rpush("window", 0000, redis.print)
# redclient.rpush("window", 0001, redis.print)
# redclient.lrange("window", 0, 10000, redis.print)
# 
# redclient.linsert("window", 'BEFORE', 0001, 9999, redis.print)
# redclient.lrange("window", 0, 10000, redis.print)

# redclient.zadd(WINDOWID, 3, "blah", redis.print)
# 
# console.log "counting set:"
# redclient.zcount(WINDOWID, 0, 100000, redis.print)
    
redclient.flushall(redis.print)

###
redclient.rpush(WINDOWID, "test1", redis.print)
redclient.rpush(WINDOWID, "test2", redis.print)
redclient.rpush(WINDOWID, "test3", redis.print)
redclient.lindex(WINDOWID, 1, (error, result) ->
    console.log "error: #{error}"
    console.log "result: #{result}"
)
###

handleSocket = (socket) ->
    
    # socket.emit('tabAdded', {'index': 0, 'url':"http://google.com/"})

    
    # socket.emit('news', { hello: 'world' })
        
    socket.on('tabAdded', (tab) ->  
        
        console.log "tab added:"
        console.log tab

        id = tab['id']
        
        redclient.set(id, JSON.stringify(tab), redis.print)
        console.log "tab index: #{tab['index']}"
        redclient.lindex(WINDOWID, tab['index'], (error, result) ->
            console.log "currently at that index: #{result}"
            if result?
                console.log "inserting before result: #{result}"
                redclient.linsert(WINDOWID, 'BEFORE', result, id, redis.print)
            else
                console.log "inserting at the end."
                redclient.rpush(WINDOWID, id, redis.print)
        )
        
        redclient.lrange(WINDOWID, 0, 10000, redis.print)
        
        # redclient.zadd(WINDOWID, tab['index'], tab['id'], redis.print)
            
        socket.emit('tabId', {clientId: tab['id'], serverId: id })
        socket.broadcast.emit('tabAdded', tab)        
        # for key of data
        #     redclient.set(key, data[key], redis.print)
        # for key of data
        #     redclient.get(key, redis.print)
    )
    
    socket.on('tabRemoved', (tab) ->
        console.log "tab removed:"
        console.log tab
        
        redclient.del(tab['id'], redis.print)
        
        redclient.lrem(WINDOWID, 1, tab['id'], redis.print)
        
        socket.broadcast.emit('tabRemoved', tab)
        

        
    )
    
    socket.on('tabUpdated', (tab) ->
        console.log "tab updated:"
        console.log tab
        
        redclient.set(tab['id'], JSON.stringify(tab), redis.print)
        
        socket.broadcast.emit('tabUpdated', tab)
    )
    
    socket.on('tabMoved', (tab) ->
        console.log "tab moved:"
        console.log tab
        
        id = tab['id']
        
        redclient.set(id, JSON.stringify(tab), redis.print)
                
        redclient.lrem(WINDOWID, 1, tab['id'], redis.print)
        
        redclient.lindex(WINDOWID, tab['index'], (error, result) ->
            console.log "currently at that index: #{result}"
            if result?
                console.log "inserting before result: #{result}"
                redclient.linsert(WINDOWID, 'BEFORE', result, id, redis.print)
            else
                console.log "inserting at the end."
                redclient.rpush(WINDOWID, id, redis.print)
        )
        
        socket.broadcast.emit('tabMoved', tab)
        
    )
    
    socket.on('getAll', (windowId) ->
        console.log "getting all tabs for #{windowId}"
        redclient.lrange(windowId, 0, -1, (err, res) ->
            for key of res
                console.log "tab id: " + res[key]
                redclient.get(res[key], (err2, res2) ->
                    console.log "tab data: " 
                    console.log res2
                    socket.emit('tabAdded', res2)
                )
        )
    )
    
    
    
    
    
    
    
    
    
    
    
    
    
    
exports.handleSocket = handleSocket