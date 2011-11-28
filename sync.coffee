# SERVER = "http://strong-mist-1633.herokuapp.com"
SERVER = "http://18.111.108.63:8888"

# $( () -> 
#     # alert "storage watcher set"
#     $(window).bind('storage', (e) ->
#         console.log(e)
#         if e.originalEvent.key == "windowId"
#             alert "starting..."
#             start()
#     )
# )

chrome.extension.onRequest.addListener( (request, sender, sendResponse) ->
    # alert "got a message!"

    if request.type = "createWindow"

        # alert "making a window"
        chrome.windows.create({}, (window) ->
            # alert "made a window"
            localStorage['windowId'] = window['id']
            start()
            if request.newWindow
                socket.emit('makeWindowId')
                localStorage['serverWindowId'] = null
            else
                localStorage['serverWindowId'] = request.windowId
                socket.emit('getAll', localStorage['serverWindowId'])
        )

)

#----------------------------------------------------------------------
# maps local tab id to server tab id and vice versa
# should be a data structure with appropriate methods

fromClientTabMapping = {}
fromServerTabMapping = {}
addTabMapping = (clientId, serverId) ->
    fromClientTabMapping[clientId] = serverId
    fromServerTabMapping[serverId] = clientId
    
removeTabMappingByClientId = (clientId) ->
    serverId = getServerTabId(clientId)
    delete fromClientTabMapping[clientId]
    delete fromServerTabMapping[serverId]
    return ServerId
    
removeTabMappingByServerId = (serverId) ->
    clientId = getClientTabId(serverId)
    delete fromClientTabMapping[clientId]
    delete fromServerTabMapping[serverId]
    return clientId
    
getServerTabId = (clientId) ->
    fromClientTabMapping[clientId]
    
getClientTabId = (serverId) ->
    fromServerTabMapping[serverId]

#----------------------------------------------------------------------    
# maps local window id to server window id and vice versa
# should be a data structure with appropriate methods

### this seems unnecessary. only need one.
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
###

# serverWindowId = null

#----------------------------------------------------------------------

tabsFromServer = {}

start = () ->
    
    # alert "Started up!"
    
    window.socket = io.connect(SERVER)
    # alert "socket: " + window.socket
    socket = window.socket ? null

        
    chrome.tabs.getAllInWindow(+localStorage['windowId'], (tabs) ->
        if tabs[0]?
            onTabCreatedHandler(tabs[0])
    )

    socket.on('tabAdded', (data) ->
        
        
        # tab = JSON.parse(data)
        tab = data
        if tab['windowId'] != localStorage['serverWindowId']
            return
        
        if getClientTabId(tab['id'])?
            return
            
        serverTabId = tab['id']
            
        delete tab['id']
        tab.windowId = +localStorage['windowId']
        # alert tab
        
        tab['selected'] = false
        
        # create the tab and map its local id to the server id
        tabsFromServer[tab['url']] = 1
        chrome.tabs.create(tab, (newTab) ->
            addTabMapping(newTab['id'], serverTabId)
        )
    )
    
    socket.on('tabId', (data) ->
        console.log "tabId received"
        if data['windowId'] != localStorage['serverWindowId']
            return
        
        addTabMapping(data['clientId'], data['serverId'])
    )
    
    socket.on('windowId', (data) ->
        console.log "windowId received"
        localStorage['serverWindowId'] = data['windowId']
    )
    
    socket.on('tabRemoved', (tab) ->
        console.log "tabRemoved received: "
        console.log tab
        if tab['windowId'] != localStorage['serverWindowId']
            return
        
        clientTabId = removeTabMappingByServerId(tab['id'])
        chrome.tabs.remove(clientTabId)
    )
    
    
    socket.on('tabMoved', (tab) ->
        console.log "tabMoved received:"
        console.log tab
        if tab['windowId'] != localStorage['serverWindowId']
            return
        
        clientTabId = getClientTabId(tab['id'])
        chrome.tabs.move(clientTabId, {index: tab['index']})
    )
    
    socket.on('tabUpdated', (tab) ->
        console.log "tabUpdated received:"
        console.log tab
        if tab['windowId'] != localStorage['serverWindowId']
            return
        
        clientTabId = getClientTabId(tab['id'])
        chrome.tabs.update(clientTabId, {url: tab['url']})
    )
    
    chrome.tabs.onDetached.addListener(onTabDetachedHandler)
    chrome.tabs.onRemoved.addListener(onTabRemovedHandler)
    chrome.tabs.onAttached.addListener(onTabAttachedHandler)
    chrome.tabs.onCreated.addListener(onTabCreatedHandler)
    chrome.tabs.onMoved.addListener(onTabMovedHandler)
    chrome.tabs.onUpdated.addListener(onTabUpdatedHandler)
    

onTabDetachedHandler = (tabId, detachedInfo) ->
    # socket = window.socket ? null
    chrome.tabs.get(tabId, (tab) -> 
        # alert "tab detached: #{tab}"
        if tab['windowId'] != +localStorage['windowId']
            # alert "detached tab was not in correct window"
            return
        
        socket.emit('tabRemoved', { 'windowId': localStorage['serverWindowId'], 'url': tab['url'], 'index': tab['index'], 'id': getServerTabId(tab['id']) })
    )
    
onTabRemovedHandler = (tabId, removedInfo) ->
    if not removedInfo['isWindowClosing']
        # alert "tab removed!"
        if getServerTabId(tabId)?
            socket.emit('tabRemoved', { 'windowId': localStorage['serverWindowId'], 'id': getServerTabId(tabId) })

onTabCreatedHandler = (tab) ->
    
    if getServerTabId(tab['id'])?
        return
        
    if tabsFromServer[tab['url']]?
        tabsFromServer[tab['url']] = null
        return
    
    if tab['windowId'] != +localStorage['windowId']
        return
    
    # alert "tab window IS equal to stored window"
    socket.emit('tabAdded', { 'windowId': localStorage['serverWindowId'], url: tab['url'], index: tab['index'], id: tab['id'] })


onTabAttachedHandler = (tabId, addedInfo) ->

    if getServerTabId(tabId)?
        return
        
    chrome.tabs.get(tabId, (tab) ->
        if tab['windowId'] != +localStorage['windowId']
            return
        socket.emit('tabAdded', { 'windowId': localStorage['serverWindowId'], url: tab['url'], index: tab['index'], id: tab['id'] })
    )
    
onTabUpdatedHandler = (tabId, changeInfo) -> 

    # alert "tab updated"

    if not changeInfo['url']?
        return

    chrome.tabs.get(tabId, (tab) -> 
        if tab['windowId'] != +localStorage['windowId']
            # alert "updated tab in wrong window"
            return
        # alert "updating tab on server..."
        socket.emit('tabUpdated', { 'windowId': localStorage['serverWindowId'], url: tab['url'], index: tab['index'], id: getServerTabId(tab['id']) })
    )
    
onTabMovedHandler = (tabId, moveInfo) -> 

    chrome.tabs.get(tabId, (tab) -> 
        if tab['windowId'] != +localStorage['windowId']
            # alert "wrong window!"
            return
        socket.emit('tabMoved', {'windowId': localStorage['serverWindowId'], url: tab['url'], index: moveInfo['toIndex'], oldIndex: moveInfo['fromIndex'], id: getServerTabId(tabId)})
    )
    
###
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
###

















