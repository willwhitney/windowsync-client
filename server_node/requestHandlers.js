(function() {
  var fs, start;
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
  exports.start = start;
}).call(this);
