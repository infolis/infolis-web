BodyParser = require 'body-parser'
Vim2Html   = require 'vim2html'

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


	app.post '/api/syntax-highlight', BodyParser.text(), (req, res, next) ->
		res.header 'Content-Type', 'text/html'
		opts = {
			syntax: 'n3'
			colorscheme: 'seoul256-light'
			number_lines: 0
			use_css: 0
			pre_only: 1
		}
		type2syntax = {
			'text/turtle': 'javascript'
		}
		Vim2Html.highlightString req.body.text, opts, (err, highlighted) ->
			# console.log highlighted
			if err
				return next err
			res.send highlighted
