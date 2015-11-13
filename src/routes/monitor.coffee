Async = require 'async'
Request = require 'superagent'
CONFIG = require '../config'

module.exports = (app, opts) ->
	opts or= {}

	app.get '/api/stats', (req, res, next) ->
		stats = {}
		Async.forEachOf app.schemo.models, (model, modelName, cb) ->
			stats[modelName] = {}
			model.count (err, nr) ->
				stats[modelName].count = nr
				cb()
		, (err) ->
			res.send stats

	app.get '/api/monitor', (req, res, next) ->
		Request
			.get("#{CONFIG.backendURI}/executor?status=#{req.query.status}")
			.set 'Accept', 'application/json'
			.end (err, startResp) ->
				if err
					return next err
				return res.send startResp.body

