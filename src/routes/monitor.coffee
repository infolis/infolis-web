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
			model.collection.indexInformation (err, indexInfo) ->
				stats[modelName].indexedFields = []
				for k,v of indexInfo
					continue if v[0][0] is '_id'
					stats[modelName].indexedFields.push v[0][0]
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
			.end (err, getAllResp) ->
				if err
					return next err
				allExecutions = []
				Async.map getAllResp.body, (uri, cb) ->
					Request
						.get(uri)
						.set 'Accept', 'application/json'
						.end (err, getOneResp) ->
							return cb() if err
							getOneResp.body.uri = uri
							allExecutions.push getOneResp.body
							return cb()
				, (err) ->
					statuses = ["PENDING", "STARTED", "FINISHED", "FAILED"]
					byStatus = {}
					byStatus[v] = [] for v in statuses
					for execution in allExecutions
						if execution
							byStatus[execution.status].push execution
					for k,v of byStatus
						byStatus[k] = v.sort (a,b) -> new Date(a.startTime) - new Date(b.startTime)
					allExecutions = allExecutions.sort (a,b) -> new Date(a.startTime) - new Date(b.startTime)
					if Accepts(req).types().length > 0 and Accepts(req).types()[0] is 'text/html'
						return res.render 'monitor', { byStatus, statuses, allExecutions }
					else
						return res.send allExecutions

