SchemaFactory = require 'mongoose-jsonld/src'
ExpressJSONLD = require 'express-jsonld/src'
InfolisSchema = require 'infolis-schema/src/infolis-schema'
config        = require '../config'

module.exports = setupRoutes = (app, opts) ->
	opts or= {}

	if not app.db
		throw new Error("Must set the MongoDB connection for API")

	infolisSchema = new InfolisSchema(
		dbConnection: app.db
	)

	jsonldMiddleware = new ExpressJSONLD(
		jsonldRapper: infolisSchema.mongooseJSONLD.jsonldRapper
	).getMiddleware()

	# For all the models in our schema
	for __, model of infolisSchema.models
		# Load the model's RESTful handlers into app
		infolisSchema.mongooseJSONLD.injectRestfulHandlers(app, model)
		# Load the model's schema handler
		infolisSchema.mongooseJSONLD.injectSchemaHandlers(app, model)
	
	# Schema handler for the ontology
	app.get(
		infolisSchema.mongooseJSONLD.schemaPrefix,
		(req, res, next) ->
			req.jsonld = infolisSchema.jsonldTBox()
			next()
		jsonldMiddleware)
