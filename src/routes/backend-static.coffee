CONFIG = require '../config'
Request = require 'superagent'
module.exports = (app, done) ->

	# Swagger interface
	app.get '/backend/:id*?', (req, res, next) ->
		Request
			.get("#{CONFIG.backendURI}/#{CONFIG.backendStaticPath}/#{req.params.id}")
			.end (err, backendResp) ->
				console.log backendResp
				res.send backendResp

	done()


