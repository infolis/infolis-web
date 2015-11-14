### 
# Some Module

###
Async         = require 'async'
Merge         = require 'merge'
Express       = require 'express'
Mongoose      = require 'mongoose'
BodyParser    = require 'body-parser'
TSON          = require 'tson'
Cors          = require 'cors'
StringifySafe = require 'json-stringify-safe'

ExpressJSONLD  = require 'express-jsonld/src'
Schemo = require 'mongoose-jsonld/src'

CONFIG = require './config'

log = require('./log')(module)

errorHandler = (err, req, res, next) ->
	if typeof err is 'string'
		err = {'message': err}
	else if err instanceof Error
		flatErr = {}
		Object.getOwnPropertyNames(err).map (p) ->
			flatErr[p] = err[p]
		err = flatErr
	log.error StringifySafe err
	delete err.arguments
	res.status = 400
	res.send StringifySafe err, null, 2

class InfolisWebservice

	constructor: (@port) ->
		log.silly "Configuration", CONFIG
		@app = Express()
		# Start DB
		@app.db = Mongoose.createConnection(
			CONFIG.mongoURI
			CONFIG.mongoServerOptions
		)
		if not @app.db
			throw new Error("Must set the MongoDB connection for API")
		@app.db.on 'error', (e) =>
			log.error "ERROR starting MongoDB"
			throw e
		# Schemo!
		@app.schemo = new Schemo(
			mongoose: @app.db
			baseURI: CONFIG.baseURI
			apiPrefix: CONFIG.apiPrefix
			schemaPrefix: CONFIG.schemaPrefix
			expandContexts: CONFIG.expandContexts
			htmlFormat: 'text/html'
			htmlView: 'triples'
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
		# Jade
		@app.set('views', './views')
		@app.set('view engine', 'jade')
		# Make it easy for routes to add swagger docs
		@app._swagger = {}
		@app.swagger = (endpoint, def) ->
			return @_swagger if not (endpoint and def)
			log.debug "Adding swagger for #{endpoint}"
			@_swagger[endpoint] = def

	setupRoutes : () ->
		for controller in [
				'restful'
				'schemo'
				'upload'
				'execute'
				'monitor'
				'ldf'
				'swagger'
				'json-import'
			]
			do (controller) =>
				log.info "Setting up route #{controller}"
				require("./routes/#{controller}")(@app)
		# root route
		@app.get '/', (req, res, next) ->
			res.render 'swagger'
			# res.status 302
			# res.header 'Location', '/infolink/swagger/'
			# res.end()
		# Error handler
		@app.use errorHandler

	startServer : () ->
		log.info "Setting up routes"
		@setupRoutes()
		log.info "Starting server on #{CONFIG.port}"
		@app.on 'error', (e) ->
			log.error e
		@app.listen CONFIG.port

server = new InfolisWebservice()
server.startServer()

# ALT: test/test.coffee
