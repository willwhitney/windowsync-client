(function() {
  var SERVER;
  SERVER = "http://937860c6.dotcloud.com/windowmanager.php";
  chrome.windows.create({}, function(window) {
    return localStorage['windowId'] = window['id'];
  });
}).call(this);
