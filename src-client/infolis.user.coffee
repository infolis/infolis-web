client = new InfolinkClient(
	baseURI: 'http://infolis.gesis.org/infolink'
)

$('head').append(
	$('<link rel="stylesheet">')
		.attr('href', client.baseURI + '/gm-progressbar.css'))

$('body').prepend(
	$('<div>')
		.attr('id', 'infolis-modal')
		.css('position', 'fixed')
		.css('top', '0')
		.css('left', '0')
		.css('right', '0')
		.css('height', '200px')
		.css('background', 'white')
		.css('border', '5px solid #2277b0')
		.append("<span>Download:</span>")
		.append($("<div>").addClass('download'))
		.append("<span>Upload:</span>")
		.append($("<div>").addClass('upload'))
		.hide())

runOnElem = () ->
	$("#infolis-modal").show()
	uri = $(this).attr('data-infolis')
	Bootstrap.createProgressBar('download', '#infolis-modal .download')
	Bootstrap.createProgressBar('upload', '#infolis-modal .upload')
	client.GM_downloadBlob uri,
		onStarted: ->
		onProgress: (ev) ->
			perc = 100 * (ev.loaded / ev.total)
			Bootstrap.setProgressBar('download', perc).text(perc + "%")
		onSuccess: (blob) ->
			# notie.alert(1, 'Download finished', 0.5)
			client.uploadBlob blob,
				tags: ['kba-gm-test']
				onProgress : (ev) ->
					if ev.percent
						Bootstrap.setProgressBar('upload', ev.percent).text(ev.percent + "%")
				onError: ->
					console.error arguments
				onSuccess : (ev) ->
					notie.alert(1, 'Upload to ', 0.5)
					Bootstrap.setProgressBar('upload', 100).text("100%")

infolisTo = (elem) ->
	link = $(elem).closest('a[href]').attr('href')
	# $(elem).parent(':not(:has(img[data-infolis]))').append(
	$(elem).removeAttr('href').append(
		$("<img class>")
			.css('width', '32px')
			.css('height', '32px')
			.attr('src', 'http://infolis.github.io/img/logo-circle.png')
			.attr('data-infolis', link)
			.on 'click', runOnElem)
	

LocalMain = -> 
	infolisTo($("a img[src*='pdf']").parents('a[href]'))

window.addEventListener "load", LocalMain, false
