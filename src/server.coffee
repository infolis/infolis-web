###
# Some Module

###
Async         = require 'async'
Accepts       = require 'accepts'
Fs            = require 'fs'
Merge         = require 'merge'
Express       = require 'express'
Mongoose      = require 'mongoose'
BodyParser    = require 'body-parser'
TSON          = require 'tson'
Cors          = require 'cors'
StringifySafe = require 'json-stringify-safe'
Morgan        = require 'morgan'

ExpressJSONLD  = require 'express-jsonld/src'
Schemo = require 'mongoose-jsonld/src'

CONFIG = require './config'

log = require('./log')(module)

notFoundHandler = (req, res, next) ->
	res.status 404
	if Accepts(req).type('text/html')
		return res.render '404', {reqJSON: StringifySafe(req, null, 2)}
	else
		return res.end()
	next()

errorHandler = (err, req, res, next) ->
	if typeof err is 'string'
		err = {'message': err}
	else if err instanceof Error
		flatErr = {}
		Object.getOwnPropertyNames(err).map (p) ->
			flatErr[p] = err[p]
		err = flatErr
	log.error "ERROR", StringifySafe err
	delete err.arguments
	res.status 400
	if Accepts(req).type('text/html')
		return res.render 'error', { err }
	else
		res.send StringifySafe err, null, 2

accessLogger = Morgan 'combined', stream: Fs.createWriteStream(__dirname + '/../data/logs/access.log', {flags: 'a'})
accessLoggerDev = Morgan 'dev'

class InfolisWebservice

	constructor: (@port) ->
		log.silly "Configuration", CONFIG
		@app = Express()
		# Very important, that next one
		@app.set('case sensitive routing', true)
		# Start DB
		@app.mongoose = Mongoose.createConnection(
			CONFIG.mongoURI
			CONFIG.mongoServerOptions
		)
		if not @app.mongoose
			throw new Error("Must set the MongoDB connection for API")
		@app.mongoose.on 'error', (e) =>
			log.error "ERROR starting MongoDB"
			throw e
		# Schemo!
		@app.schemo = new Schemo(
			mongoose: @app.mongoose
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
		# Forward proxy remote address
		@app.set("trust proxy", 'loopback')
		# Make it easy for routes to add swagger docs
		@app._swagger = {}
		@app.swagger = (endpoint, def) ->
			return @_swagger if not (endpoint and def)
			log.debug "Adding swagger for #{endpoint}"
			@_swagger[endpoint] = def

	setupRoutes : () ->
		# @app.http().io()
		# Store site information
		@app.use (req, res, next) ->
			res.locals.CONFIG = CONFIG
			res.locals.site_api = CONFIG.site_api
			res.locals.site_github = CONFIG.site_github
			if req.query.site_github
				res.locals.site_github = req.query.site_github
			next()
		# Log access
		@app.use accessLogger
		@app.use accessLoggerDev
		controllers = [
			'header'
			'restful'
			'schemo'
			'upload'
			'execute'
			'monitor'
			'ldf'
			'swagger'
			'json-import'
			'syntax-highlight'
			'tson'
			'greasemonkey'
			'play'
		]
		Async.eachSeries controllers, (controller, done) =>
			log.info "Setting up route #{controller}"
			require("./routes/#{controller}")(@app, done)
		, (err, next) =>
			# root route
			@app.get '/', (req, res, next) ->
				res.status 302
				res.header 'Location', CONFIG.site_github
				res.end()
			# Error handler
			@app.use errorHandler
			# 404 handler
			@app.use notFoundHandler

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
