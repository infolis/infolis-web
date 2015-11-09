Request = require 'superagent'
CONFIG = require '../config'

module.exports = (app, opts) ->
	opts or= {}

	app.get '/api/monitor', (req, res, next) ->
		Request
			.get("#{CONFIG.backendURI}/executor?status=#{req.query.status}")
			.set 'Accept', 'application/json'
			.end (err, startResp) ->
				if err
					return next err
				return res.send startResp.body

