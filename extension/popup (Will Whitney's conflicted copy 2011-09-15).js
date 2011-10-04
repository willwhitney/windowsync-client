(function() {
  var SERVER, urls;
  SERVER = "http://937860c6.dotcloud.com/windowmanager.php";
  chrome.windows.create({
    url: "http://google.com/",
    focused: true
  });
  urls = [];
  $.get(SERVER, {
    type: "get"
  }, function(data) {
    var tab, _i, _len, _ref;
    alert("got data from server");
    _ref = JSON.parse(data);
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      tab = _ref[_i];
      urls.push(tab['url']);
    }
    return chrome.windows.create({
      url: urls,
      focused: true
    }, function(window) {
      localStorage['window'] = window['id'];
      if (urls.length === 0) {
        return $.get(SERVER, {
          type: "add",
          url: "chrome://newtab/",
          tabindex: 0
        }, function(data) {});
      }
    });
  });
}).call(this);
