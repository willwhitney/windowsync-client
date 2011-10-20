(function() {
  var handleEvent;
  handleEvent = function() {
    return socket.on('other event', function(data) {
      return console.log(data);
    });
  };
  exports.handle = handle;
}).call(this);
