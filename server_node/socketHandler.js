(function() {
  var handleSocket, redclient, redis;
  redis = require("redis");
  redclient = redis.createClient();
  redclient.on("error", function(err) {
    return console.log("redis error: " + err);
  });
  handleSocket = function(socket) {
    socket.emit('tabAdded', {
      'index': 0,
      'url': "http://google.com/"
    });
    socket.on('tabAdded', function(tab) {
      var id;
      console.log("tab added:");
      console.log(tab);
      socket.broadcast.emit('tabAdded', tab);
      id = tab['id'];
      redclient.set(id, tab, redis.print);
      return socket.emit('tabId', {
        clientId: tab['id'],
        serverId: id
      });
    });
    socket.on('tabRemoved', function(tab) {
      console.log("tab removed:");
      console.log(tab);
      socket.broadcast.emit('tabRemoved', tab);
      return redclient.del(tab['id'], redis.print);
    });
    socket.on('tabUpdated', function(tab) {
      console.log("tab updated:");
      console.log(tab);
      socket.broadcast.emit('tabUpdated', tab);
      return redclient.set(tab['id'], tab, redis.print);
    });
    return socket.on('tabMoved', function(tab) {
      console.log("tab moved:");
      return console.log(tab);
    });
  };
  exports.handleSocket = handleSocket;
}).call(this);
