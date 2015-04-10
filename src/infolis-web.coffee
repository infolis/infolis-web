### 
# Some Module

###
Async      = require 'async'
Merge      = require 'merge'
Mongoose   = require 'mongoose'
Express    = require 'express'
Chalk      = require 'chalk'
BodyParser = require 'body-parser'

InfolisSchema  = require 'infolis-schema/src'
ExpressJSONLD  = require 'express-jsonld/src'
MongooseJSONLD = require 'mongoose-jsonld/src'

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
			baseURI: CONFIG.baseURI
			apiPrefix: CONFIG.apiPrefix
			schemaPrefix: CONFIG.schemaPrefix
			expandContexts: CONFIG.expandContexts
		)

		@app.jsonldMiddleware = new ExpressJSONLD(@app.mongooseJSONLD).getMiddleware()

		@app.infolisSchema = new InfolisSchema(
			dbConnection: @app.db
			mongooseJSONLD: @app.mongooseJSONLD
		)

		# JSON body serialization middleware
		@app.use(BodyParser.json())

		# Setup routes
		for controller in ['jsonld-api', 'upload']
			require("./routes/#{controller}")(@app)

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
