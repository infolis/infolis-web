$ = require 'jquery'
Request = require 'superagent'

if typeof window isnt 'undefined'
	exp = window
else if typeof self isnt 'undefined'
	exp = self
else
	exp = module.exports

exp.InfolinkClient = class InfolinkClient

	constructor: (@baseURI, @apiPrefix, @schemaPrefix) ->
		@baseURI or= 'http://infolis.gesis.org/infolink'
		@apiPrefix or= '/api'
		@schemaPrefix or= '/schema'

	_apiUrl: (endpoint) -> "#{@baseURI}#{@apiPrefix}/#{endpoint}"

	syntaxHighlight: (opts = {}) ->
		onError   = opts.onError   or -> console.error(arguments)
		onSuccess = opts.onSuccess or ->
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
