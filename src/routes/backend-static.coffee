CONFIG = require '../config'
Request = require 'superagent'
module.exports = (app, done) ->

	# Swagger interface
	app.get '/backend/:id*?', (req, res, next) ->
		Request
			.get("#{CONFIG.backendURI}/#{CONFIG.backendStaticPath}/#{req.params.id}")
			.end (err, backendResp) ->
				if backendResp.headers['content-type']
					res.header 'content-type', backendResp.headers['content-type']
				res.status backendResp.statusCode
				res.send backendResp.text

	done()


