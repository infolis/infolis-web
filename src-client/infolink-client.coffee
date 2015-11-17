Request = require 'superagent'

module.exports = class InfolinkClient

	constructor: (@baseURI, @apiPrefix, @schemaPrefix) ->
		@baseURI or= 'http://infolis.gesis.org/infolink'
		@apiPrefix or= '/api'
		@schemaPrefix or= '/schema'

	_apiUrl: (endpoint) -> "#{@baseURI}#{@apiPrefix}/#{endpoint}"

	syntaxHighlight: (text, format) ->
		Request
			.post(_apiUrl 'syntax-highlight')
			.send {text, format}
			.end (err, res) ->
				console.log err, res
