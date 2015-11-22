Accepts    = require 'accepts'
TSON       = require 'tson'
Vim2Html   = require 'vim2html'
Fs         = require 'fs'
CONFIG     = require '../config'

log = require('../log')(module)

TSON_SCHEMA = Fs.readFileSync(__dirname + '/../../data/infolis.tson').toString()
TSON_AS_JSON = TSON.parse TSON_SCHEMA
TSON_CLASSES = []
TSON_PROPS = []
for tsonClass of TSON_AS_JSON
	continue if tsonClass.indexOf('@') > -1
	TSON_CLASSES.push tsonClass
	for tsonProp of TSON_AS_JSON[tsonClass]
		continue if tsonProp.indexOf('@') > -1
		TSON_PROPS.push tsonProp
temp = {}
temp[v] = v for v in TSON_CLASSES
temp[v] = v for v in TSON_PROPS
TSON_ALL = Object.keys temp

module.exports = (app, done) ->

	app.get '/play/data-model-explorer', (req, res, next) ->
		res.render 'demo-data-model',
			tson: TSON_AS_JSON,
			tsonClasses: TSON_CLASSES,
			tsonProps: TSON_PROPS,
			tsonAll: TSON_ALL

	app.get '/api/tson', (req, res, next) ->
		opts = {
			syntax: 'turtleson'
			colorscheme: CONFIG.colorscheme
			number_lines: 0
			use_css: 0
			pre_only: 1
		}
		if Accepts(req).type('text/html')
			Vim2Html.highlightString TSON_SCHEMA, opts, (err, highlighted) ->
				if err
					return next err
				res.render 'tson', {tson:highlighted}
		else if Accepts(req).type('text/vnd.tson')
			res.header 'Content-Type', 'text/vnd.tson'
			res.send TSON_SCHEMA
		else
			res.header 'Content-Type', 'application/json'
			res.send TSON_AS_JSON

	done()
