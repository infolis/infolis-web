module.exports = (app, done) ->

	app.get '/play/publicationmask', (req, res, next) ->
		res.render 'play/publicationmask'

	done()
