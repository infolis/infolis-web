CONFIG = require '../config'
Request = require 'superagent'

log = require('../log')(module)

module.exports = (app, done) ->

	# Swagger interface
	app.get '/backend/*', (req, res, next) ->
		uri = "#{CONFIG.backendURI}/#{CONFIG.backendStaticPath}/#{req.params[0]}"
		log.debug "Retrieving static backend asset '#{uri}'"
		Request
			.get(uri)
			.end (err, backendResp) ->
				if backendResp.headers['content-type']
					res.header 'content-type', backendResp.headers['content-type']
				res.status backendResp.statusCode
				res.send backendResp.text

	done()


