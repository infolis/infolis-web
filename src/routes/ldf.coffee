
module.exports = (app, opts) ->
	opts or= {}

	app.get '/api/ldf', (req, res, next) ->
		res.end()
