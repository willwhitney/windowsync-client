(function() {
  var SERVER, addTabMapping, fromClientTabMapping, fromServerTabMapping, getClientTabId, getServerTabId, onTabAttachedHandler, onTabCreatedHandler, onTabDetachedHandler, onTabMovedHandler, onTabRemovedHandler, onTabUpdatedHandler, removeTabMappingByClientId, removeTabMappingByServerId, start, tabsFromServer;
  SERVER = "http://18.111.108.63:8888";
  chrome.extension.onRequest.addListener(function(request, sender, sendResponse) {
    if (request.type = "createWindow") {
      return chrome.windows.create({}, function(window) {
        localStorage['windowId'] = window['id'];
        start();
        if (request.newWindow) {
          socket.emit('makeWindowId');
          return localStorage['serverWindowId'] = null;
        } else {
          localStorage['serverWindowId'] = request.windowId;
          return socket.emit('getAll', localStorage['serverWindowId']);
        }
      });
    }
  });
  fromClientTabMapping = {};
  fromServerTabMapping = {};
  addTabMapping = function(clientId, serverId) {
    fromClientTabMapping[clientId] = serverId;
    return fromServerTabMapping[serverId] = clientId;
  };
  removeTabMappingByClientId = function(clientId) {
    var serverId;
    serverId = getServerTabId(clientId);
    delete fromClientTabMapping[clientId];
    delete fromServerTabMapping[serverId];
    return ServerId;
  };
  removeTabMappingByServerId = function(serverId) {
    var clientId;
    clientId = getClientTabId(serverId);
    delete fromClientTabMapping[clientId];
    delete fromServerTabMapping[serverId];
    return clientId;
  };
  getServerTabId = function(clientId) {
    return fromClientTabMapping[clientId];
  };
  getClientTabId = function(serverId) {
    return fromServerTabMapping[serverId];
  };
  /* this seems unnecessary. only need one.
  fromClientWindowMapping = {}
  fromServerWindowMapping = {}
  addWindowMapping = (clientId, serverId) ->
      fromClientWindowMapping[clientId] = serverId
      fromServerWindowMapping[serverId] = clientId
      
  removeWindowMappingByClientId = (clientId) ->
      serverId = getServerTabId(clientId)
      fromClientWindowMapping.del(clientId)
      fromServerWindowMapping.del(serverId)
      return ServerId
  
  removeWindowMappingByServerId = (serverId) ->
      clientId = getClientWindowId(serverId)
      fromClientWindowMapping.del(clientId)
      fromServerWindowMapping.del(serverId)
      return clientId
  
  getServerWindowId = (clientId) ->
      fromClientWindowMapping[clientId]
  
  getClientWindowId = (serverId) ->
      fromServerWindowMapping[serverId]
  */
  tabsFromServer = {};
  start = function() {
    var socket, _ref;
    window.socket = io.connect(SERVER);
    socket = (_ref = window.socket) != null ? _ref : null;
    chrome.tabs.getAllInWindow(+localStorage['windowId'], function(tabs) {
      if (tabs[0] != null) {
        return onTabCreatedHandler(tabs[0]);
      }
    });
    socket.on('tabAdded', function(data) {
      var serverTabId, tab;
      tab = data;
      if (tab['windowId'] !== localStorage['serverWindowId']) {
        return;
      }
      if (getClientTabId(tab['id']) != null) {
        return;
      }
      serverTabId = tab['id'];
      delete tab['id'];
      tab.windowId = +localStorage['windowId'];
      tab['selected'] = false;
      tabsFromServer[tab['url']] = 1;
      return chrome.tabs.create(tab, function(newTab) {
        return addTabMapping(newTab['id'], serverTabId);
      });
    });
    socket.on('tabId', function(data) {
      console.log("tabId received");
      if (data['windowId'] !== localStorage['serverWindowId']) {
        return;
      }
      return addTabMapping(data['clientId'], data['serverId']);
    });
    socket.on('windowId', function(data) {
      console.log("windowId received");
      return localStorage['serverWindowId'] = data['windowId'];
    });
    socket.on('tabRemoved', function(tab) {
      var clientTabId;
      console.log("tabRemoved received: ");
      console.log(tab);
      if (tab['windowId'] !== localStorage['serverWindowId']) {
        return;
      }
      clientTabId = removeTabMappingByServerId(tab['id']);
      return chrome.tabs.remove(clientTabId);
    });
    socket.on('tabMoved', function(tab) {
      var clientTabId;
      console.log("tabMoved received:");
      console.log(tab);
      if (tab['windowId'] !== localStorage['serverWindowId']) {
        return;
      }
      clientTabId = getClientTabId(tab['id']);
      return chrome.tabs.move(clientTabId, {
        index: tab['index']
      });
    });
    socket.on('tabUpdated', function(tab) {
      var clientTabId;
      console.log("tabUpdated received:");
      console.log(tab);
      if (tab['windowId'] !== localStorage['serverWindowId']) {
        return;
      }
      clientTabId = getClientTabId(tab['id']);
      return chrome.tabs.update(clientTabId, {
        url: tab['url']
      });
    });
    chrome.tabs.onDetached.addListener(onTabDetachedHandler);
    chrome.tabs.onRemoved.addListener(onTabRemovedHandler);
    chrome.tabs.onAttached.addListener(onTabAttachedHandler);
    chrome.tabs.onCreated.addListener(onTabCreatedHandler);
    chrome.tabs.onMoved.addListener(onTabMovedHandler);
    return chrome.tabs.onUpdated.addListener(onTabUpdatedHandler);
  };
  onTabDetachedHandler = function(tabId, detachedInfo) {
    return chrome.tabs.get(tabId, function(tab) {
      if (tab['windowId'] !== +localStorage['windowId']) {
        return;
      }
      return socket.emit('tabRemoved', {
        'windowId': localStorage['serverWindowId'],
        'url': tab['url'],
        'index': tab['index'],
        'id': getServerTabId(tab['id'])
      });
    });
  };
  onTabRemovedHandler = function(tabId, removedInfo) {
    if (!removedInfo['isWindowClosing']) {
      if (getServerTabId(tabId) != null) {
        return socket.emit('tabRemoved', {
          'windowId': localStorage['serverWindowId'],
          'id': getServerTabId(tabId)
        });
      }
    }
  };
  onTabCreatedHandler = function(tab) {
    if (getServerTabId(tab['id']) != null) {
      return;
    }
    if (tabsFromServer[tab['url']] != null) {
      tabsFromServer[tab['url']] = null;
      return;
    }
    if (tab['windowId'] !== +localStorage['windowId']) {
      return;
    }
    return socket.emit('tabAdded', {
      'windowId': localStorage['serverWindowId'],
      url: tab['url'],
      index: tab['index'],
      id: tab['id']
    });
  };
  onTabAttachedHandler = function(tabId, addedInfo) {
    if (getServerTabId(tabId) != null) {
      return;
    }
    return chrome.tabs.get(tabId, function(tab) {
      if (tab['windowId'] !== +localStorage['windowId']) {
        return;
      }
      return socket.emit('tabAdded', {
        'windowId': localStorage['serverWindowId'],
        url: tab['url'],
        index: tab['index'],
        id: tab['id']
      });
    });
  };
  onTabUpdatedHandler = function(tabId, changeInfo) {
    if (!(changeInfo['url'] != null)) {
      return;
    }
    return chrome.tabs.get(tabId, function(tab) {
      if (tab['windowId'] !== +localStorage['windowId']) {
        return;
      }
      return socket.emit('tabUpdated', {
        'windowId': localStorage['serverWindowId'],
        url: tab['url'],
        index: tab['index'],
        id: getServerTabId(tab['id'])
      });
    });
  };
  onTabMovedHandler = function(tabId, moveInfo) {
    return chrome.tabs.get(tabId, function(tab) {
      if (tab['windowId'] !== +localStorage['windowId']) {
        alert("wrong window!");
        return;
      }
      return socket.emit('tabMoved', {
        'windowId': localStorage['serverWindowId'],
        url: tab['url'],
        index: moveInfo['toIndex'],
        oldIndex: moveInfo['fromIndex'],
        id: getServerTabId(tabId)
      });
    });
  };
  /*
  updateLocalTablist = () ->
      # ("window #{ localStorage['window'] }")
      # alert("tabs in this window: #{ tablist }")
  
      try
          chrome.tabs.getAllInWindow(+localStorage['window'], (windowtabs) ->
              tablist = windowtabs
          )
      catch error
          console.log("error updating local tablist")
  
      # alert("finished updateTablist")
      
  
  
  onTabCreatedHandler = (tab) ->
      
      # chrome.windows.getCurrent((window) ->
      #     alert "window: #{ window['id'] }"
      # )
  
      if tab['windowId'] != +localStorage['window']
          return
  
      $.get(SERVER, {type: "add", url: tab['url'], tabindex: tab['index']}, (data) -> 
          # alert(data)
      )
  
      updateLocalTablist()
  
      # chrome.tabs.get(tabid, (tab) ->
      #     $.get(SERVER, {type: "add", url: tab['url'], tabindex: tab['index']}, (data) -> 
      #         alert(data)
      #     )
      # )
  
  onTabRemovedHandler = (tabid, removedinfo) ->
  
      if removedinfo['isWindowClosing'] or !tablist?
          return
  
      for tab in tablist
          if tab['id'] is tabid
              $.get(SERVER, {type: "remove", url: tab['url'], tabindex: tab['index']}, (data) -> 
                  # alert(data)
              )
              break
  
      # chrome.tabs.get(tabid, (tab) -> 
      #     # alert("Removed tab has data: #{ tab }")
      #     $.get(SERVER, {type: "remove", url: tab['url'], tabindex: tab['index']}, (data) -> 
      #         # alert(data)
      #     )
      # )
  
  
  
      updateLocalTablist()
  
  
  
  onTabAttachedHandler = (tabid, addedInfo) ->
      # alert "Tab added!"
  
      chrome.tabs.get(tabid, (tab) ->
          if tab['windowId'] != +localStorage['window']
              return
          $.get(SERVER, {type: "add", url: tab['url'], tabindex: tab['index']}, (data) -> 
              # alert(data)
          )
      )
  
      updateLocalTablist()
  
  
  onTabDetachedHandler = (tabid, detachedInfo) ->
      # alert "Tab removed!"
  
      chrome.tabs.get(tabid, (tab) -> 
          if tab['windowId'] != +localStorage['window']
              return
          $.get(SERVER, {type: "remove", url: tab['url']}, (data) -> 
              # alert(data)
          )
      )
  
      updateLocalTablist()
  
  onTabMovedHandler = (tabid, moveInfo) -> 
      
      chrome.tabs.get(tabid, (tab) -> 
          if tab['windowId'] != +localStorage['window']
              return
          $.get(SERVER, {type: "move", url: tab['url'], fromindex: moveInfo['fromIndex'], toindex: moveInfo['toIndex']}, (data) -> 
              # alert(data)
          )
      )
  
      updateLocalTablist()
  
  onTabUpdatedHandler = (tabid, changeInfo) -> 
      
      if not changeInfo['url']?
          return
      
  
  
      chrome.tabs.get(tabid, (tab) -> 
          if tab['windowId'] != +localStorage['window']
              return
  
          
          # alert "tabid: #{ tab['id'] }"
          if !tablist?
              updateLocalTablist()
              setTimeout(
                  () -> onTabUpdatedHandler(tabid, changeInfo), 
                  1000)
              return
  
          for oldtab in tablist
              
              # alert "oldid: #{ oldtab['id'] }"
              if +oldtab['id'] is +tab['id']
                  # alert "updated!"
                  $.get(SERVER, {type: "update", newurl: tab['url'], oldurl: oldtab['url'], tabindex: tab['index']}, (data) -> 
                      # alert(data)
                  )
                  break
  
  
      )
  
      updateLocalTablist()
  
  
  
  pullChanges = () ->
  
      # alert "pulling changes..."
      # if firstrun
      #     alert "first run!"
      #     firstrun = false
  
      updateLocalTablist()
      if !tablist?
          setTimeout(pullChanges, 5000)
          return
  
      # alert "pulling changes..."
  
      # alert "tablist.length is " + tablist.length
  
      $.get(SERVER, {type: "get"}, (data) -> 
          index = 0
          for tab in JSON.parse(data)
              # alert "tablist.length is " + tablist.length + " and index is " + index
              # alert tab['url']
              if index < tablist.length
                  # alert "i can update"
                  if tablist[index]['status'] == "complete" and tablist[index]['url'] != tab['url']
                      chrome.tabs.update(tablist[index]['id'], {url: tab['url']})
              else
                  # alert "creating new tab..."
                  chrome.tabs.create({windowId: +localStorage['window'], url: tab['url']})
              index++
          while index < tablist.length
              chrome.tabs.remove(tablist[index]['id'])
              index++
              # found = false
              # for localtab in tablist
              #     if tab['url'] == localtab['url']
              #         # alert tab['url']
              #         chrome.tabs.move(localtab['tabId'], {index: +tab['tabindex']})
              #         found = true
              # if !found
              #     alert "not found!"
              #     chrome.tabs.create({windowId: +localStorage['window'], url: tab['url'], index: +tab['tabindex']})
      )
      updateLocalTablist()
      setTimeout(pullChanges, 5000)
  
  startup = () ->
  
      # firstrun = true
      chrome.tabs.onDetached.addListener(onTabDetachedHandler)
      chrome.tabs.onRemoved.addListener(onTabRemovedHandler)
      chrome.tabs.onAttached.addListener(onTabAttachedHandler)
      chrome.tabs.onCreated.addListener(onTabCreatedHandler)
      chrome.tabs.onMoved.addListener(onTabMovedHandler)
      chrome.tabs.onUpdated.addListener(onTabUpdatedHandler)
  
      
  
      updateLocalTablist()
      pullChanges()
  */
}).call(this);
