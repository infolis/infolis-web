BodyParser    = require 'body-parser'
Pygmentize = require 'pygmentize-bundled-cached'

module.exports = (app, opts) ->
	opts or= {}

	app.swagger '/api/syntax-highlight', 
		post:
			tags: ['helper']
			summary: "Post text and receive syntax highlighted text"
			consumes: ['text/plain']
			produces: ['text/html']
			parameters: [
				name: 'text'
				in: "body"
				description: "Execution to POST"
				required: true
			]
			responses:
				200:
					description: 'Successfully highlighted'


	app.post '/api/syntax-highlight', BodyParser.text(), (req, res, next) ->
		res.header 'Content-Type', 'text/html'
		Pygmentize {lang:'turtle', format: 'html'}, req.body, (err, highlighted) ->
			if err
				next err
			res.send highlighted
