### 
# Some Module

###
Async      = require 'async'
Merge      = require 'merge'
Mongoose   = require 'mongoose'
Express    = require 'express'
Chalk      = require 'chalk'
BodyParser = require 'body-parser'
Cors       = require 'cors'

ExpressJSONLD  = require 'express-jsonld'
MongooseJSONLD = require 'mongoose-jsonld/src'

InfolisSchema  = require './schema'

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
	res.status = 400
	res.send err


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

		@app.mongooseJSONLD = new MongooseJSONLD(
			mongoose: Mongoose
			baseURI: CONFIG.baseURI
			apiPrefix: CONFIG.apiPrefix
			schemaPrefix: CONFIG.schemaPrefix
			expandContexts: CONFIG.expandContexts
			htmlFormat: 'text/turtle'
		)

		@app.jsonldMiddleware = new ExpressJSONLD(@app.mongooseJSONLD).getMiddleware()

		@app.infolisSchema = new InfolisSchema(
			dbConnection: @app.db
			mongooseJSONLD: @app.mongooseJSONLD
		)

		# JSON body serialization middleware
		@app.use(BodyParser.json())

		# CORS (Access-Control-Allow-Origin)
		@app.use(Cors())

		# Static files
		@app.use(Express.static('public'))

		# Setup routes
		for controller in ['jsonld-api', 'upload', 'execute', 'swagger']
			require("./routes/#{controller}")(@app)

		@app.get '/', (req, res, next) ->
			res.status 302
			res.header 'Location', '/infolink/swagger/'
			res.end()
			# res.send 'API on /api, Schema/Ontology on /schema. Check http://github.com/infolis/infolis-schema'

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
