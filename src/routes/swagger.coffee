CONFIG = require '../config'
module.exports = setupRoutes = (app, opts) ->
	models = []
	for __, model of app.infolisSchema.models
		models.push model

	swaggerDef = {
		basePath: "/infolink#{CONFIG.apiPrefix}"
		info:
			title: 'Infolis YAY'
	}

	app.infolisSchema.mongooseJSONLD.injectSwaggerHandler(app, models, swaggerDef)
