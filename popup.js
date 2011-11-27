(function() {
  var newWindow, oldWindow;
  newWindow = function() {
    return chrome.extension.sendRequest({
      type: "createWindow",
      newWindow: true
    }, function(response) {
      return console.log(response);
    });
    /*
        chrome.windows.create({}, (window) ->
            localstorage['serverWindowId'] = null
            localStorage['windowId'] = window['id']
        )
        */
  };
  oldWindow = function() {
    return chrome.extension.sendRequest({
      type: "createWindow",
      newWindow: false,
      windowId: $('#window_id').val()
    }, function(response) {
      return console.log(response);
    });
    /*
        chrome.windows.create({}, (window) ->
            localStorage['windowId'] = window['id']
        )
        */
  };
  window.newWindow = newWindow;
  window.oldWindow = oldWindow;
}).call(this);
