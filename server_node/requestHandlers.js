(function() {
  var WINDOWID, fs, redclient, redis, start;
  fs = require('fs');
  redis = require("redis");
  redclient = redis.createClient();
  WINDOWID = 000000;
  redclient.on("error", function(err) {
    return console.log("redis error: " + err);
  });
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
