### 
# Some Module

###
MongooseJSONLDExpress = require 'mongoose-jsonld-express/src'
Async                 = require 'async'
Merge                 = require 'merge'
InfolisSchema         = require 'infolis-schema/src/infolis-schema'
Mongoose              = require 'mongoose'
Express               = require 'express'
Chalk                 = require 'chalk'
BodyParser            = require 'body-parser'
ExpressJSONLD         = require 'express-jsonld/src'

class InfolisWebservice

	constructor: () ->
		@infolisSchema = new InfolisSchema(
			dbConnection: Mongoose.createConnection('mongodb://localhost:27018/test')
		)
		@mongooseJSONLD = new MongooseJSONLDExpress (
			baseURL: 'http://www-test.bib-uni-mannheim.de/infolis'
			apiPrefix: '/api'
			expandContext: 'basic'
		)
		@app = Express()
		@setupRoutes()
	
	setupRoutes : () ->
		# JSON body serialization middleware
		@app.use(BodyParser.json())

		jsonLdMiddleware = ExpressJSONLD().handle

		# Load the models from the schema
		for __, model of @infolisSchema.mongoose.model
			@mongooseJSONLD.injectRestfulHandlers(@app, model, jsonLdMiddleware)

		# @app.use(jsonLdMiddleware)

		# Load the schema

		# Error handlerk
		@app.use (err, req, res, next) ->
			console.log "<ERROR>"
			console.log err
			console.log "</ERROR>"
			res.send 400, err

	startServer : (port) ->

		console.log Chalk.yellow "Starting server"
		@app.listen port

server = new InfolisWebservice()
server.startServer 3000



# ALT: test/test.coffee
