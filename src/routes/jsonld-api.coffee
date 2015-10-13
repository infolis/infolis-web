module.exports = setupRoutes = (app, opts) ->
	opts or= {}

	models = []
	for __, model of app.infolisSchema.models
		models.push model
	# For all the models in our schema
	for model in models
		# Load the model's RESTful handlers into app
		app.infolisSchema.mongooseJSONLD.injectRestfulHandlers(app, model)
		# Load the model's schema handler
		app.infolisSchema.mongooseJSONLD.injectSchemaHandlers(app, model)
	
	# Schema handler for the ontology
	app.get(
		app.infolisSchema.mongooseJSONLD.schemaPrefix,
		(req, res, next) ->
			req.jsonld = app.infolisSchema.jsonldTBox()
			next()
		app.jsonldMiddleware)
