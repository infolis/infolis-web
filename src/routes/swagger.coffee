module.exports = (app, opts) ->
	opts or= {}

	# swagger handler
	app.schemo.handlers.swagger.inject app, {
		basePath: "/infolink"
		info:
			title: 'Infolis YAY'
		tags: [
			{
				name: 'rest-ld-all'
				description: 'RESTfully access the data model'
			}
			{
				name: 'helper'
				description: "Helpers. RESTful they ain't but useful they ain'tn't."
			}
		]
		paths: app.swagger()
	}
