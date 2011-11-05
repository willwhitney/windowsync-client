(function() {
  var WINDOWID, handleSocket, redclient, redis;
  redis = require("redis");
  redclient = redis.createClient();
  WINDOWID = 000000;
  redclient.on("error", function(err) {
    return console.log("redis error: " + err);
  });
  redclient.flushall(redis.print);
  /*
  redclient.rpush(WINDOWID, "test1", redis.print)
  redclient.rpush(WINDOWID, "test2", redis.print)
  redclient.rpush(WINDOWID, "test3", redis.print)
  redclient.lindex(WINDOWID, 1, (error, result) ->
      console.log "error: #{error}"
      console.log "result: #{result}"
  )
  */
  handleSocket = function(socket) {
    socket.on('tabAdded', function(tab) {
      var id;
      console.log("tab added:");
      console.log(tab);
      id = tab['id'];
      redclient.set(id, JSON.stringify(tab), redis.print);
      console.log("tab index: " + tab['index']);
      redclient.lindex(WINDOWID, tab['index'], function(error, result) {
        console.log("currently at that index: " + result);
        if (result != null) {
          console.log("inserting before result: " + result);
          return redclient.linsert(WINDOWID, 'BEFORE', result, id, redis.print);
        } else {
          console.log("inserting at the end.");
          return redclient.rpush(WINDOWID, id, redis.print);
        }
      });
      redclient.lrange(WINDOWID, 0, 10000, redis.print);
      socket.emit('tabId', {
        clientId: tab['id'],
        serverId: id
      });
      return socket.broadcast.emit('tabAdded', tab);
    });
    socket.on('tabRemoved', function(tab) {
      console.log("tab removed:");
      console.log(tab);
      redclient.del(tab['id'], redis.print);
      redclient.lrem(WINDOWID, 1, tab['id'], redis.print);
      return socket.broadcast.emit('tabRemoved', tab);
    });
    socket.on('tabUpdated', function(tab) {
      console.log("tab updated:");
      console.log(tab);
      redclient.set(tab['id'], JSON.stringify(tab), redis.print);
      return socket.broadcast.emit('tabUpdated', tab);
    });
    socket.on('tabMoved', function(tab) {
      var id;
      console.log("tab moved:");
      console.log(tab);
      id = tab['id'];
      redclient.set(id, JSON.stringify(tab), redis.print);
      redclient.lrem(WINDOWID, 1, tab['id'], redis.print);
      redclient.lindex(WINDOWID, tab['index'], function(error, result) {
        console.log("currently at that index: " + result);
        if (result != null) {
          console.log("inserting before result: " + result);
          return redclient.linsert(WINDOWID, 'BEFORE', result, id, redis.print);
        } else {
          console.log("inserting at the end.");
          return redclient.rpush(WINDOWID, id, redis.print);
        }
      });
      return socket.broadcast.emit('tabMoved', tab);
    });
    return socket.on('getAll', function(windowId) {
      console.log("getting all tabs for " + windowId);
      return redclient.lrange(windowId, 0, -1, function(err, res) {
        var key, _results;
        _results = [];
        for (key in res) {
          console.log("tab id: " + res[key]);
          _results.push(redclient.get(res[key], function(err2, res2) {
            console.log("tab data: ");
            console.log(res2);
            return socket.emit('tabAdded', res2);
          }));
        }
        return _results;
      });
    });
  };
  exports.handleSocket = handleSocket;
}).call(this);
