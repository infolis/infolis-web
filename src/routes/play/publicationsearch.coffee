module.exports = (app, done) ->

	app.get '/play/publicationsearch', (req, res, next) ->
		res.render 'play/publicationsearch'

	done()