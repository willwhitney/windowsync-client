
newWindow = () ->
    # alert "pre-callback"
    
    chrome.extension.sendRequest({type: "createWindow", newWindow: true}, (response) ->
        console.log(response)
    )

    ###
    chrome.windows.create({}, (window) ->
        localstorage['serverWindowId'] = null
        localStorage['windowId'] = window['id']
    )
    ###

oldWindow = () ->
    
    chrome.extension.sendRequest({type: "createWindow", newWindow: false, windowId: $('#window_id').val() }, (response) ->
        console.log(response)
    )
    ###
    chrome.windows.create({}, (window) ->
        localStorage['windowId'] = window['id']
    )
    ###
    
window.newWindow = newWindow
window.oldWindow = oldWindow





	
	# $.get(SERVER, {type: "get"}, (data) -> 
	# 	alert "got data from server: #{data}"
	# 	for tab in JSON.parse(data)
	# 		# document.write(tab['url'])
	# 		chrome.tabs.create({windowId: window, index: tab['tabindex'], url: tab['url']})
		
		

	# 	# chrome.windows.create({url: urls, focused: true}, (window) ->
	# 	# 	localStorage['window'] = window['id']
	# 	# 	if urls.length == 0
	# 	# 		$.get(SERVER, {type: "add", url: "chrome://newtab/", tabindex: 0}, (data) -> 
	#  #        	)
	# 	# )
	# )

	








