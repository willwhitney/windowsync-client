(function() {
  var SERVER, newWindow, oldWindow;
  SERVER = "http://937860c6.dotcloud.com/windowmanager.php";
  newWindow = function() {
    return chrome.windows.create({}, function(window) {
      localstorage['serverWindowId'] = null;
      return localStorage['windowId'] = window['id'];
    });
  };
  oldWindow = function() {
    return chrome.windows.create({}, function(window) {
      localstorage['serverWindowId'] = null;
      return localStorage['windowId'] = window['id'];
    });
  };
}).call(this);
