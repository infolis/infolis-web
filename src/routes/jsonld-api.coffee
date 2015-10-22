module.exports = setupRoutes = (app, opts) ->
	opts or= {}

	# console.log app.schemo.models
	# For all the models in our schema
	for modelName, model of app.schemo.models
		# Load the model's RESTful handlers into app
		# app.schemo.injectRestfulHandlers(app, model)
		# Load the model's schema handler
		app.schemo.injectSchemaHandlers(app, model)
	
	# Schema handler for the ontology, i.e. /schema
	app.get(app.schemo.schemaPrefix,
		(req, res, next) ->
			req.jsonld = app.schemo.jsonldTBox()
			next()
		app.jsonldMiddleware)
