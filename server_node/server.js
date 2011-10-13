(function() {
  var http, socketio, start, url;
  http = require("http");
  url = require("url");
  socketio = require("socket.io");
  start = function(route, handle) {
    var app, io, onRequest;
    onRequest = function(request, response) {
      var pathname;
      pathname = url.parse(request.url).pathname;
      console.log("request for " + pathname + " received.");
      return route(handle, pathname, response);
    };
    app = http.createServer(onRequest);
    io = socketio.listen(app);
    app.listen(8888);
    console.log("server started");
    return io.sockets.on('connection', function(socket) {
      socket.emit('news', {
        hello: 'world'
      });
      return socket.on('other event', function(data) {
        return console.log(data);
      });
    });
  };
  exports.start = start;
}).call(this);
