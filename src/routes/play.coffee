BodyParser = require 'body-parser'

log = require('../log')(module)

module.exports = (app, opts) ->
	opts or= {}

	app.get '/play/demo1', (req, res, next) ->
		res.render 'demo-upload'

