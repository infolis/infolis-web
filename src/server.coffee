### 
# Some Module

###
Async         = require 'async'
Merge         = require 'merge'
Mongoose      = require 'mongoose'
Express       = require 'express'
Chalk         = require 'chalk'
BodyParser    = require 'body-parser'
TSON          = require 'tson'
Cors          = require 'cors'
StringifySafe = require 'json-stringify-safe'

ExpressJSONLD  = require 'express-jsonld'
Schemo = require 'mongoose-jsonld/src'

CONFIG = require './config'

errorHandler = (err, req, res, next) ->
	if typeof err is 'string'
		err = {'message': err}
	else if err instanceof Error
		flatErr = {}
		Object.getOwnPropertyNames(err).map (p) ->
			flatErr[p] = err[p]
		err = flatErr
	# console.log "<ERROR>"
	# console.log err
	# console.log "</ERROR>"
	# throw err
	# next JSON.stringify(err, null, 2)
	# err = Object.keys(err)
	delete err.arguments
	res.status = 400
	res.send StringifySafe err, null, 2


class InfolisWebservice

	constructor: (@port) ->
		@app = Express()

		# Start DB
		@app.db = Mongoose.createConnection(
			CONFIG.mongoURI
			CONFIG.mongoServerOptions
		)
		if not @app.db
			throw new Error("Must set the MongoDB connection for API")
		@app.db.on 'error', (e) =>
			console.log Chalk.red "ERROR starting MongoDB"
			throw e
		# Schemo!
		@app.schemo = new Schemo(
			mongoose: @app.db
			baseURI: CONFIG.baseURI
			apiPrefix: CONFIG.apiPrefix
			schemaPrefix: CONFIG.schemaPrefix
			expandContexts: CONFIG.expandContexts
			htmlFormat: 'text/turtle'
			schemo: TSON.load __dirname + '/../data/infolis.tson'
		)
		# JSON-LD Middleware
		@app.jsonldMiddleware = @app.schemo.expressJsonldMiddleware
		# JSON body serialization middleware
		@app.use(BodyParser.json())
		# CORS (Access-Control-Allow-Origin)
		@app.use(Cors())
		# Static files
		@app.use(Express.static('public'))
		# Setup routes
		for controller in [
				'restful'
				'schemo'
				'upload'
				'execute'
				'monitor'
				'swagger'
			]
			do (controller) =>
				console.log "Setting up route #{controller}"
				require("./routes/#{controller}")(@app)
		# root route
		@app.get '/', (req, res, next) ->
			res.status 302
			res.header 'Location', '/infolink/swagger/'
			res.end()
		# Error handler
		@app.use errorHandler

	startServer : () ->
		console.log Chalk.yellow "Starting server on #{CONFIG.port}"
		@app.on 'error', (e) ->
			console.log Chalk.red e
		@app.listen CONFIG.port

server = new InfolisWebservice()
server.startServer()

# ALT: test/test.coffee
