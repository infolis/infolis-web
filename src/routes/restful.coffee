module.exports = (app, opts) ->
	opts or= {}

	# restful handlers
	app.schemo.handlers.restful.inject(app)

