SERVER = "http://937860c6.dotcloud.com/windowmanager.php"

chrome.windows.create({}, (window) ->
    localStorage['windowId'] = window['id']

)

	
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

	








