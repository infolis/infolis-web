$        = require 'jquery'
Async    = require 'async'
Request  = require 'superagent'

if typeof window isnt 'undefined'
	exp = window
else if typeof self isnt 'undefined'
	exp = self
else
	exp = module.exports

_onErrorDefault = (err) ->
	if not err
		console.error "There was an error "
	if err.status is 400
		console.error JSON.parse err.response.text
	else
		console.error err

_onSuccessDefault = (res) ->
	console.log 'YAY', res

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
		selector  = opts.selector
		if 'text' not of opts
			return onError "Must provide 'text'"
		text = opts.text
		if 'mimetype' not of opts
			return onError "Must provide 'mimetype'"
		mimetype = opts.mimetype
		Request
			.post(@_apiUrl 'syntax-highlight')
			.send { text, mimetype }
			.end (err, res) ->
				if err
					return onError err, res
				if selector
					$(selector).html(res.text)
				console.log res
				return onSuccess res.text, res

	uploadFile: (opts = {}) ->
		if typeof opts isnt 'object'
			opts = selector: opts
		onError   = opts.onError   or _onErrorDefault
		onSuccess = opts.onSuccess or _onSuccessDefault
		if 'selector' not of opts
			return onError "Must provide 'selector'"
		file = $(opts.selector).get(0).files[0]
		if not file
			return onError "No file found in selector 'selector'"
		if 'mediaType' not of opts
			opts.mediaType = file.type
		formData = new FormData()
		formData.append 'file', file
		formData.append 'mediaType', opts.mediaType
		Request
			.post(@_apiUrl 'upload')
			.set 'accept', 'application/json'
			.send(formData)
			.end (err, res) ->
				if err
					return onError err
				return onSuccess res
