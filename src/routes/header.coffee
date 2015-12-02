module.exports = (app, done) ->

	app.get '/_header', (req, res, next) ->
		res.render 'include/header'

	done()

