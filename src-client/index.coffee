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

_noop = ->

_onErrorDefault = (err) ->
	if not err
		console.error "There was an error "
	if err.status is 400
		errObj = JSON.parse(err.response.text)
		if 'cause' of errObj
			console.error errObj.cause
		else
			console.error errObj
	else
		console.error err

_onSuccessDefault = (res) ->
	console.log 'YAY', res

_onProgressDefault = (ev) ->
	console.log ev

_requireArg = (arg) -> "Must provide '#{arg}' argument"

exp.InfolinkClient = class InfolinkClient

	constructor: (@baseURI, @apiPrefix, @schemaPrefix) ->
		@baseURI or= 'http://infolis.gesis.org/infolink'
		@apiPrefix or= '/api'
		@schemaPrefix or= '/schema'
		# @io = require('socket.io-client').connect(@baseURI)
		# @io.connect()
		# @io.emit('ready')
		# @io.on 'talk', (data) ->
		#     console.log(data)


	_apiUrl: (endpoint) -> "#{@baseURI}#{@apiPrefix}/#{endpoint}"

	syntaxHighlight: (opts = {}) ->
		onError   = opts.onError   or _onErrorDefault
		onSuccess = opts.onSuccess or _onSuccessDefault
		for required in ['text', 'mimetype']
			if required not of opts
				return onError _requireArg required
		text = opts.text
		mimetype = opts.mimetype
		Request
			.post(@_apiUrl 'syntax-highlight')
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
			return _onErrorDefault _requireArg 'opts'
		onError    = opts.onError    or _onErrorDefault
		onStarted  = opts.onStarted  or _noop
		onSuccess  = opts.onSuccess  or _onSuccessDefault
		onProgress = opts.onProgress or _onProgressDefault
		for required in ['text', 'mimetype']
			if required not of opts
				return onError _requireArg required
		# TODO

	uploadFiles: (opts = {}) ->
		if typeof opts isnt 'object'
			opts = selector: opts
		onError    = opts.onError    or _onErrorDefault
		onStarted  = opts.onStarted  or _noop
		onSuccess  = opts.onSuccess  or _onSuccessDefault
		onProgress = opts.onProgress or _onProgressDefault
		if 'selector' not of opts
			return onError _requireArg 'selector'
		fileList = $(opts.selector).get(0).files
		if not fileList
			return onError 'No files specified'
		fileArray = (file for file in fileList)
		Async.each fileArray, (file, done) =>
			fileIdx = fileArray.indexOf(file)
			onStarted {fileIdx, file}
			formData = new FormData()
			formData.append 'file', file
			formData.append 'mediaType', file.type
			Request
				.post(@_apiUrl 'upload')
				.set 'accept', 'application/json'
				.send(formData)
				.on 'progress', (ev) ->
					ev.fileIdx = fileIdx
					ev.file = file
					onProgress ev
				.end (err, res) ->
					if err
						return onError {fileIdx, err, file}
					uri = res.headers.location
					return onSuccess {fileIdx, file, uri}
