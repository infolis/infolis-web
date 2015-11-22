CONFIG = require '../config'
log = require('../log')(module)

module.exports = (app, done) ->

	app.get '/play/infolis.meta.js', (req, res, next) ->
		res.header 'Content-Type', 'text/javascript'
		res.render 'infolis.meta.js.jade', { CONFIG }

	app.get '/play/infolis.user.js', (req, res, next) ->
		res.header 'Content-Type', 'text/javascript'
		res.render 'infolis.user.js.jade', { CONFIG }

	done()
