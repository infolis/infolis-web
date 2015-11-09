module.exports = setupRoutes = (app, opts) ->
	opts or= {}

	# schema handlers
	app.schemo.handlers.schema.inject(app)

	# Schema handler for the ontology, i.e. /schema
	app.get(app.schemo.schemaPrefix,
		(req, res, next) ->
			req.jsonld = app.schemo.jsonldTBox()
			next()
		app.jsonldMiddleware)
