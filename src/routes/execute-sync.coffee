Async  = require 'async'
CONFIG = require '../config'
Request = require 'superagent'
InfolinkClient = require('../../src-client').InfolinkClient

module.exports = (app, done) ->

	app.swagger '/api/execute-sync',
		post:
			tags: ['essential']
			summary: "Post an execution, execute it on the backend and wait for it to finish."
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
	app.post '/api/execute-sync', (req, res, next) ->
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
						res.send '@link': executionUri
						return res.end()

	done()
