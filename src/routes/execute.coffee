{Form} = require 'multiparty'
Async  = require 'async'
Crypto = require 'crypto'
Fs     = require 'fs'
CONFIG = require '../config'
Request = require 'superagent'

module.exports = setupRoutes = (app, opts) ->
	opts or= {}

	app.post '/api/execute', (req, res, next) ->
		form = new Form()
		form.parse req, (err, fields, files) ->
			if err
				return next new Error(err)
			executionModel = new app.infolisSchema.models.Execution()
			executionModel.set fields
			executionModel.set 'status', 'PENDING'
			console.log executionModel
			Request
				.post("#{CONFIG.baseURI}/#{CONFIG.apiPrefix}/execution")
				.send(executionModel)
				.end (err, postResp) ->
					# console.log postResp
					if err
						return res.send new Error(err)
					else if postResp.status != 201
						return next new Error(JSON.stringify(postResp, null, 2))
					executionUri = postResp.headers['location']
					backUri = "#{CONFIG.backendURI}/executor?id=#{executionUri}"
					Request
						.post(backUri)
						.end (err, startResp) ->
							if err
								return next new Error(err)
							res.header 'Location', executionUri
							res.status 200
							return res.end()
