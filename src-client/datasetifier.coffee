class Demo1

	constructor: () ->
		$('.toggleable').hide()
		$('#start-demo').on 'click', () =>
			@uploadTags = []
			for tag in $("#upload-tags").val().trim().split(/\s*,\s*/)
				@uploadTags.push tag
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
				$("a", bar).attr('href', ev.uri).append(" -> #{ev._id}")
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
			execution:
				tags: @uploadTags
			onStarted : (execution) ->
				console.log 'Started text extraction', execution
				self.reveal("#text-extractor-progress")
				bar = Bootstrap.createProgressBar(execution._id, '#text-extractor-progress')
				bar.html($("<a>").attr("href",execution.uri).append(execution._id))
			onError: (execution) ->
				notie.alert(3, 'Text extraction error', 0.5)
			onProgress : (execution) ->
				Bootstrap.setProgressBar(execution._id, execution.progress)
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
				zebar = null
				infolinkClient.applyPatternAndResolve execution.outputFiles, "demo3",
					onStarted : (execution) ->
						console.log 'Started ApplyPatternAndResolve', execution
						self.reveal("#links")
						self.reveal("#apar-uri")
						self.reveal("#apar-progress")
						zebar = Bootstrap.createProgressBar('apar', '#apar-progress')
						zebar.html($("<a>").attr("href",execution.uri).append(execution._id))
					onError: (execution) ->
						notie.alert(3, 'apar error', 0.5)
					onProgress : (exec) ->
						$("#apar-uri").html($("<a>").attr('href',exec.uri).text(exec.uri))
						Bootstrap.setProgressBar('apar', exec.progress).text(exec.progress)
					onComplete : (execution) ->
						if execution.status is 'FAILED'
							console.error "APAR failed", execution
							notie.alert(6, 'Apply Pattern And Resolve failed :(', 0.5)
							Bootstrap.getProgressBar('apar').addClass('progress-bar-danger')
							return
						Bootstrap.setProgressBar('apar', 100)
						Bootstrap.getProgressBar('apar').addClass('progress-bar-success')
						notie.alert(1, 'Apply Pattern And Resolve complete :)', 0.5)
						for uri in execution.links
							$("#links").append(
								$("<li>").append($("<a>").attr("href", uri).html(uri)))

$ ->
	demo1 = new Demo1()
