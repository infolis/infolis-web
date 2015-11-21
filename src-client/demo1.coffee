class Demo1

	constructor: () ->
		$('#start-demo').on 'click', () =>
			@reset()
			@uploadFiles()

	reset: () ->
		$(".toggleable").hide()

	uploadFiles: ->
		self = this
		infolinkClient.uploadFiles
			selector: "#file"
			onStarted: (ev) =>
				self.reveal("#upload-progress")
				bar = Bootstrap.createProgressBar("file-#{ev.fileIdx}", '#upload-progress')
				bar.html($("<a>").css('color', 'white').html(ev.file.name))
			onProgress: (ev) ->
				Bootstrap.setProgressBar("file-#{ev.fileIdx}", ev.percent)
			onError: (ev) ->
				console.error ev
				notie.alert(3, 'Upload failed', 0.5)
				Bootstrap.getProgressBar("file-#{ev.fileIdx}").addClass('progress-bar-danger')
			onSuccess: (ev) ->
				bar = Bootstrap.getProgressBar("file-#{ev.fileIdx}")
				bar.addClass('progress-bar-success')
				$("a", bar).attr('href', ev.uri).append(" -> #{ev.uri}")
			onComplete: (ev) ->
				notie.alert(1, 'Upload complete', 0.5)
				setTimeout () ->
					console.log ev
					self.extractText ev.uris
				, 1000

	reveal : (selector) ->
		$(selector).parents().show()

	extractText: (uris) ->
		self = this
		infolinkClient.extractText uris,
			onStarted : (exec) ->
				console.log 'Started text extraction', exec
				self.reveal("#text-extractor-progress")
				bar = Bootstrap.createProgressBar(exec._id, '#text-extractor-progress')
				bar.html($("<a>").attr("href",exec.uri).append(exec._id))
			onError: (exec) ->
				notie.alert(3, 'Text extraction error', 0.5)
			onProgress : (exec) ->
				Bootstrap.setProgressBar(exec._id, exec.progress)
			onComplete : (execution) ->
				if execution.status is 'FAILED'
					console.error "Text extraction failed", execution
					notie.alert(6, 'Text extraction failed :(', 0.5)
					Bootstrap.getProgressBar(execution._id).addClass('progress-bar-danger')
					return
				notie.alert(1, 'Text extraction complete :)', 0.5)
				Bootstrap.getProgressBar(execution._id).addClass('progress-bar-success')
				self.reveal("#text-output-uri")
				for uri in execution.outputFiles
					$("#text-output-uri").append(
						$("<li>").append($("<a>").attr("href", uri).html(uri)))
				self.reveal("#select-tags")

$ ->
	demo1 = new Demo1()
