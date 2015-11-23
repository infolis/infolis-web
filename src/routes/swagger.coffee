CONFIG = require '../config'
module.exports = (app, done) ->

	# Swagger interface
	app.get '/api', (req, res, next) ->
		res.render 'swagger'

	# swagger handler
	app.schemo.handlers.swagger.inject app, {
		basePath: CONFIG.basePath
		info:
			title: 'Infolis YAY'
		tags: [
			{
				name: 'advanced'
				description: "Statistics and Tools"
			}
			{
				name: 'essential'
				description: "The Essential API calls to make use of InFoLiS"
			}
		]
		paths: app.swagger()
	}, done
