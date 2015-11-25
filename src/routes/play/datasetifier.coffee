module.exports = (app, done) ->

	app.get '/play/datasetifier', (req, res, next) ->
		res.render 'play/datasetifier'

	done()
