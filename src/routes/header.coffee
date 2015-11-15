module.exports = (app, opts) ->
	opts or= {}

	app.get '/_header', (req, res, next) ->
		res.render 'header'
