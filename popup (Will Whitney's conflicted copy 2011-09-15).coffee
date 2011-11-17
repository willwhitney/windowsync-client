SERVER = "http://937860c6.dotcloud.com/windowmanager.php"

chrome.windows.create({url: "http://google.com/", focused: true})

urls = []
$.get(SERVER, {type: "get"}, (data) -> 
	alert "got data from server"
	for tab in JSON.parse(data)
		# document.write(tab['url'])
		urls.push(tab['url'])
	
	

	chrome.windows.create({url: urls, focused: true}, (window) ->
		localStorage['window'] = window['id']
		if urls.length == 0
			$.get(SERVER, {type: "add", url: "chrome://newtab/", tabindex: 0}, (data) -> 
        	)
	)
)



