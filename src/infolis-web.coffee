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

PORT = 3000
class InfolisWebservice

	constructor: (@port) ->
		@port or= 3000
		@infolisSchema = new InfolisSchema(
			dbConnection: Mongoose.createConnection('mongodb://localhost:27018/test')
		)
		@mongooseJSONLD = new MongooseJSONLDExpress (
			# baseURL: 'http://www-test.bib-uni-mannheim.de/infolis'
			baseURL: "http://localhost:#{@port}"
			apiPrefix: '/api'
			expandContext: 'basic'
		)
		@app = Express()
		@setupRoutes()
	
	setupRoutes : () ->
		# JSON body serialization middleware
		@app.use(BodyParser.json())

		# For all the models in our schema
		for __, model of @infolisSchema.mongoose.model
			# Load the model's RESTful handlers into app
			@mongooseJSONLD.injectRestfulHandlers(@app, model)
			# Load the model's schema handler
			@mongooseJSONLD.injectSchemaHandlers(@app, model)

		# Error handler
		@app.use (err, req, res, next) ->
			console.log "<ERROR>"
			console.log err
			console.log "</ERROR>"
			throw err
			res.send 400, err

	startServer : () ->

		console.log Chalk.yellow "Starting server"
		@app.listen @port

server = new InfolisWebservice()
server.startServer 3000



# ALT: test/test.coffee
