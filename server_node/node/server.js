(function() {
  var client, http, io, net, redis;
  http = require('http');
  net = require('net');
  io = require('socket.io').listen(1337);
  redis = require("redis");
  client = redis.createClient();
  client.on("error", function(err) {
    return console.log("Error " + err);
  });
  io.sockets.on('connection', function(socket) {
    socket.emit('news', "marco");
    return socket.on('my other event', function(data) {
      return console.log(data);
    });
  });
  console.log('Server running');
}).call(this);
