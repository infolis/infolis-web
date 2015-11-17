Async = require 'async'
Request = require 'superagent'
Accepts = require 'accepts'
CONFIG = require '../config'

log = require('../log')(module)

module.exports = (app, opts) ->
	opts or= {}

	app.swagger '/api/stats',
		get:
			tags: ['helper']
			summary: 'Get some statistics about the data store'
			responses:
				200: description: "Retrieved the statistics"

	app.get '/api/stats', (req, res, next) ->
		stats = {}
		Async.forEachOf app.schemo.models, (model, modelName, cb) ->
			stats[modelName] = {}
			model.count (err, nr) ->
				stats[modelName].count = nr
				cb()
		, (err) ->
			if Accepts(req).types().length > 0 and Accepts(req).types()[0] is 'text/html'
				return res.render 'stats', { stats }
			else
				res.send stats

	app.swagger '/api/monitor',
		get:
			tags: ['helper']
			summary: 'Get the status of executions live from the backend'
			responses:
				200: description: "Retrieved the executions by status"
			parameters: [
				name: 'status'
				in: 'query'
				type: 'string'
				enum: [
					'PENDING'
					'STARTED'
					'FINISHED'
					'FAILED'
				]
			]

	app.get '/api/monitor', (req, res, next) ->
		Request
			.get("#{CONFIG.backendURI}/executor?status=#{req.query.status}")
			.set 'Accept', 'application/json'
			.end (err, startResp) ->
				if err
					return next err
				Async.map startResp.body, (uri, cb) ->
					Request
						.get(uri)
						.set 'Accept', 'application/json'
						.end (err, execResp) ->
							return cb() if err
							execResp.body.uri = uri
							return cb null, execResp.body
				, (err, mapped) ->
					statuses = ["PENDING", "STARTED", "FINISHED", "FAILED"]
					byStatus = {}
					byStatus[v] = [] for v in statuses
					for execution in mapped
						if execution
							byStatus[execution.status].push execution
					if Accepts(req).types().length > 0 and Accepts(req).types()[0] is 'text/html'
						return res.render 'monitor', { byStatus, statuses }
					else
						return res.send mapped

