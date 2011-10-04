SERVER = "http://937860c6.dotcloud.com/windowmanager.php"
tablist = null

socket = io.connect('http://localhost')
socket.on('news', (data) ->
    console.log data
    socket.emit('my other event', { my: 'data' })
)

###
$( () -> 

  $(window).bind('storage', (e) ->
    alert('storage changed');
    startup()
  )

  # localStorage.setItem('a', 'test')

);


updateLocalTablist = () ->
    # alert("window #{ localStorage['window'] }")
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


















