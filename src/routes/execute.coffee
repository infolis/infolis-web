Async  = require 'async'
Crypto = require 'crypto'
Fs     = require 'fs'
CONFIG = require '../config'
Request = require 'superagent'

module.exports = (app, done) ->

	app.swagger '/api/execute',
		post:
			tags: ['essential']
			summary: "Post an execution and run it on the backend."
			consumes: ['application/json']
			parameters: [
				name: 'execution'
				in: "body"
				description: "Execution to POST"
				required: true
				schema:
					$ref: "#/definitions/Execution"
			]
			responses:
				201:
					description: 'Successfully started the execution'
					headers:
						'Location': {
							description: 'The location of the execution'
							type: 'string'
							format: 'uri'
						}
				400:
					description: 'Posting of the execution failed before execution. Verify it is valid by posting it directly.'
				500:
					description: 'Backend failed.'

	# console.log(app.io.route)
	# app.io.route 'ready', (req) ->
	#     console.log req
	#     req.io.emit 'talk', {
	#         message: 'yay'
	#     }
	app.delete '/api/execute', (req, res, next) ->
		executionUri = req.param('id')
		Request
			.delete("#{CONFIG.backendURI}/#{CONFIG.backendApiPath}/executor?id=#{executionUri}")
			.end (err, startResp) ->
				if err
					return next err
				res.header 'Location', executionUri
				res.send '@link': executionUri
				res.status 201
				return res.end()

	app.post '/api/execute', (req, res, next) ->
		exec = req.body
		exec.status = 'PENDING'
		Request
			.post("#{CONFIG.baseURI}#{CONFIG.apiPrefix}/execution")
			.send(req.body)
			.end (err, postResp) ->
				if err
					return next err
				executionUri = postResp.headers['location']
				Request
					.post("#{CONFIG.backendURI}/#{CONFIG.backendApiPath}/executor?id=#{executionUri}")
					.end (err, startResp) ->
						if err
							return next err
						res.header 'Location', executionUri
						res.send '@link': executionUri
						res.status 201
						return res.end()

	done()
