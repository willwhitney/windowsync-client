(function() {
  var fs, socket, start;
  fs = require('fs');
  start = function(response) {
    return fs.readFile('index.html', function(err, data) {
      if (err) {
        response.writeHead(500);
        return res.end('Error loading index.html');
      }
      response.writeHead(200);
      return response.end(data);
    });
  };
  socket = function(response) {
    return console.log("socket request received");
  };
  exports.start = start;
  exports.socket = socket;
}).call(this);
