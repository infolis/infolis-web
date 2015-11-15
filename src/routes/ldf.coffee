
module.exports = (app, opts) ->
	opts or= {}

	app.schemo.handlers.ldf.inject(app, opts)
