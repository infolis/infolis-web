### 
# Some Module

###
Async                 = require 'async'
Merge                 = require 'merge'
InfolisSchema         = require 'infolis-schema/src/infolis-schema'
Mongoose              = require 'mongoose'
Express               = require 'express'
Chalk                 = require 'chalk'
BodyParser            = require 'body-parser'
ExpressJSONLD         = require 'express-jsonld/src'

config = require './config'

errorHandler = (err, req, res, next) ->
	if typeof err is 'string'
		err = {'message': err}
	else if err instanceof Error
		flatErr = {}
		Object.getOwnPropertyNames(err).map (p) ->
			flatErr[p] = err[p]
		err = flatErr
	console.log "<ERROR>"
	console.log err
	console.log "</ERROR>"
	# throw err
	next err


class InfolisWebservice

	constructor: (@port) ->
		@app = Express()

		# Start DB
		@app.db = Mongoose.createConnection(
			config.mongoURI
			config.mongoServerOptions
		)

		# JSON body serialization middleware
		@app.use(BodyParser.json())
		@app.db.on 'error', (e) =>
			console.log Chalk.red "ERROR starting MongoDB"
			throw e

		# Setup routes
		# for controller in ['api', 'upload']
		for controller in ['api']
			require("./routes/#{controller}")(@app)

		# Error handler
		@app.use errorHandler

	startServer : () ->
		console.log Chalk.yellow "Starting server on #{config.port}"
		@app.on 'error', (e) ->
			console.log Chalk.red e
		@app.listen config.port

server = new InfolisWebservice()
server.startServer()

# ALT: test/test.coffee
