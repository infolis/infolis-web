Async  = require 'async'
Crypto = require 'crypto'
Fs     = require 'fs'
CONFIG = require '../config'
Request = require 'superagent'

module.exports = (app, opts) ->
	opts or= {}

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
					.post("#{CONFIG.backendURI}/executor?id=#{executionUri}")
					.end (err, startResp) ->
						if err
							return next err
						res.header 'Location', executionUri
						res.send '@link': executionUri
						res.status 201
						return res.end()
