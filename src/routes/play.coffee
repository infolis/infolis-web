BodyParser = require 'body-parser'
TSON = require 'tson'
Vim2Html   = require 'vim2html'
Fs = require 'fs'

log = require('../log')(module)

module.exports = (app, done) ->

	TSON_SCHEMA = Fs.readFileSync(__dirname + '/../../data/infolis.tson').toString()

	app.get '/play/demo1', (req, res, next) ->
		res.render 'demo-upload'

	app.get '/play/data-model', (req, res, next) ->
		tson = TSON.parse TSON_SCHEMA
		tsonClasses = []
		for tsonClass of tson
			continue if tsonClass.indexOf('@') > -1
			tsonClasses.push tsonClass
		res.render 'demo-data-model', {tson, tsonClasses}

	app.get '/play/tson', (req, res, next) ->
		opts = {
			syntax: 'turtleson'
			colorscheme: 'chrysoprase'
			number_lines: 0
			use_css: 0
			pre_only: 1
		}
		Vim2Html.highlightString TSON_SCHEMA, opts, (err, highlighted) ->
			if err
				return next err
			res.render 'tson', {tson:highlighted}

	done()
