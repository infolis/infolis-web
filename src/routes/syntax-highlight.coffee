BodyParser = require 'body-parser'
Vim2Html   = require 'vim2html'

log = require('../log')(module)

module.exports = (app, opts) ->
	opts or= {}

	app.swagger '/api/syntax-highlight', 
		post:
			tags: ['helper']
			summary: "Post text and receive syntax highlighted text"
			consumes: ['application/json']
			produces: ['text/html']
			parameters: [
				name: 'text'
				in: "body"
				description: "Text to highlight"
				required: true
			]
			parameters: [
				name: 'mimetype'
				in: "body"
				description: "mimetype"
				required: true
			]
			responses:
				200:
					description: 'Successfully highlighted'

	mimetype2syntax =
		'application/json':             'javascript'
		'application/ld+json':          'javascript'
		'application/n3+json':          'javascript'
		'application/rdf+json':         'javascript'
		'application/rdf-triples+json': 'javascript'
		'application/rdf-triples':      'n3'
		'application/x-turtle':         'n3'
		'text/rdf+n3':                  'n3'
		'application/trig':             'n3'
		'text/turtle':                  'n3'
		'application/nquads':           'n3'
		'application/ntriples':         'n3'
		'application/rdf+xml':          'xml'
		'text/xml':                     'xml'
		'text/html':                    'html'

	app.post '/api/syntax-highlight', BodyParser.text(), (req, res, next) ->
		res.header 'Content-Type', 'text/html'
		mimetype = req.body.mimetype
		if not mimetype or mimetype is ''
			mimetype = 'application/json'
		syntax = mimetype2syntax[mimetype] or 'javascript'
		log.debug "highlighting format #{mimetype} as #{syntax}"
		opts = {
			syntax: syntax
			colorscheme: 'legiblelight'
			number_lines: 0
			use_css: 0
			pre_only: 1
		}
		Vim2Html.highlightString req.body.text, opts, (err, highlighted) ->
			# console.log highlighted
			if err
				return next err
			res.send highlighted
