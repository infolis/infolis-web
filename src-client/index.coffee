$        = require 'jquery'
_        = require 'lodash'
Async    = require 'async'
Request  = require 'superagent'

if typeof window isnt 'undefined'
	exp = window
else if typeof self isnt 'undefined'
	exp = self
else
	exp = module.exports

_requireArg = (arg) -> "Must provide '#{arg}' argument"

class Bootstrap

	createProgressBar : (uri, selector) ->
		inner = $("<div>")
			.addClass("progress-bar")
			.attr("role", "progressbar")
			.css('margin-bottom', '0')
			.css('width', '0')
		bar = $("<div>")
			.addClass("progress")
			.attr('data-uri', uri)
			.css('margin-bottom', '0')
			.append(inner)
		$(selector).append(bar)
		return inner

	setProgressBar : (uri, percent) -> @getProgressBar(uri).css('width', percent + "%")
	getProgressBar : (uri) -> $(".progress[data-uri='#{uri}'] .progress-bar")

class Utils

	@replaceExtension : (fname, ext) ->
		fname.substring(0, fname.lastIndexOf(".")+1) + ext

	@lastUriSegment : (uri) ->
		if uri.indexOf('#') > -1
			return uri.substr(uri.lastIndexOf('#') + 1)
		else if uri.indexOf('/') > -1
			return uri.substr(uri.lastIndexOf('/') + 1)
		else
			return uri


class InfolinkClient

	constructor: (opts = {}) ->
		@[k] = v for k,v of opts
		@baseURI or= 'http://infolis.gesis.org/infolink'
		@apiPrefix or= '/api'
		@schemaPrefix or= '/schema'
		@pollInterval = 1000
		@debug = false
		# @io = require('socket.io-client').connect(@baseURI)
		# @io.connect()
		# @io.emit('ready')
		# @io.on 'talk', (data) ->
		#     console.log(data)

	defaultHandler:
		no_op: ->
		started: (res)  -> console.log 'STARTED', res
		success: (res)  -> console.log 'SUCCESS', res
		complete: (res) -> console.log 'COMPLETE', res
		progress: (ev)  -> console.log 'PROGRESS', ev
		error: (err) ->
			if not err
				return console.error "ERROR"
			if 'err' of err
				err = err.err
			if err.status is 400
				while 'response' of err
					err = JSON.parse err.response.text
				if 'cause' of err
					if 'errors' of err.cause
						return console.error 'ERROR (errors)', err.cause.errors
					return console.error 'ERROR (cause)', err.cause
			return console.error 'ERROR', err


	apiUrl: (endpoint) -> "#{@baseURI}#{@apiPrefix}/#{endpoint}"

	syntaxHighlight: (opts = {}) ->
		onError   = opts.onError   or @defaultHandler.error
		onSuccess = opts.onSuccess or @defaultHandler.success
		for required in ['text', 'mimetype']
			if required not of opts
				return onError _requireArg required
		text = opts.text
		mimetype = opts.mimetype
		Request
			.post(@apiUrl 'syntax-highlight')
			.send { text, mimetype }
			.end (err, res) ->
				if err
					return onError err, res
				if opts.selector
					$(opts.selector).html(res.text)
				console.log res
				return onSuccess res

	execute: (opts) ->
		if typeof opts isnt 'object'
			return @defaultHandler.error _requireArg 'opts'
		onError    = opts.onError    or @defaultHandler.error
		onStarted  = opts.onStarted  or @defaultHandler.no_op
		onSuccess  = opts.onSuccess  or @defaultHandler.success
		onProgress = opts.onProgress or @defaultHandler.progress
		onComplete = opts.onComplete or @defaultHandler.complete
		for required in ['execution']
			if required not of opts
				return onError _requireArg required
		if typeof opts.execution isnt 'object'
			return onError "Execution not an object: #{opts.execution}"
		for required in ['algorithm']
			if required not of opts.execution
				return onError _requireArg 'algorithm'
		# TODO verify opts.execution per-algorithm
		execution = opts.execution
		Request
			.post(@apiUrl 'execute')
			.set 'Accept', 'application/json'
			.send execution
			.end (err, res) =>
				if err
					return onError {execution, err}
				uri = res.headers.location
				_id = Utils.lastUriSegment(uri)
				onStarted {execution, uri, _id}
				@pollExecutionStatus uri, { onProgress, onComplete }

	pollExecutionStatus : (uri, opts) ->
		pollId = null
		poll = ->
			Request
				.get(uri)
				.set 'Accept', 'application/json'
				.end (err, res) ->
					if err
						clearTimeout pollId
						execution = {err, uri}
						opts.onProgress execution
						return opts.onComplete execution
					execution = res.body
					if execution.status in ['FINISHED','FAILED']
						clearTimeout pollId
						opts.onProgress execution
						return opts.onComplete execution
					return opts.onProgress execution
		pollId = setTimeout poll, @pollInterval

	uploadFiles: (opts = {}) ->
		if typeof opts isnt 'object'
			opts = selector: opts
		onError    = opts.onError    or @defaultHandler.error
		onStarted  = opts.onStarted  or @defaultHandler.started
		onSuccess  = opts.onSuccess  or @defaultHandler.success
		onProgress = opts.onProgress or @defaultHandler.progress
		onComplete = opts.onComplete or @defaultHandler.complete
		tags       = opts.tags or []
		if 'selector' not of opts
			return onError _requireArg 'selector'
		fileList = $(opts.selector).get(0).files
		if not fileList
			return onError 'No files specified'
		fileArray = (file for file in fileList)
		Async.map fileArray, (file, done) =>
			fileIdx = fileArray.indexOf(file)
			onStarted {fileIdx, file}
			formData = new FormData()
			formData.append 'file', file
			formData.append 'tags', tags.join(',')
			formData.append 'mediaType', file.type
			Request
				.post(@apiUrl 'upload')
				.set 'accept', 'application/json'
				.send(formData)
				.on 'progress', (ev) ->
					ev.fileIdx = fileIdx
					ev.file = file
					onProgress ev
				.end (err, res) ->
					if err
						onError {fileIdx, err, file}
						return done err
					uri = res.headers.location
					onSuccess {fileIdx, file, uri}
					done null, uri
		, (err, uris) ->
			if err
				return onError arguments
			return onComplete {uris}

	extractText: (inputFiles, opts) ->
		opts.execution or= {}
		opts.execution.algorithm = 'io.github.infolis.algorithm.TextExtractor'
		opts.execution.inputFiles = inputFiles
		return @execute opts

	applyPatterns: (inputFiles, patterns, opts) ->
		opts.execution =
			algorithm: 'io.github.infolis.algorithm.PatternApplier'
			inputFiles: inputFiles
			patterns: patterns
		return @execute opts

exp.Bootstrap = new Bootstrap()
exp.InfolinkClient = InfolinkClient
exp.Utils = Utils
