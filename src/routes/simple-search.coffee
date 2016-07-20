CONFIG = require '../config'
Async  = require 'async'
log = require('../log')(module)

module.exports = (app, done) ->

	# Swagger interface
	app.get '/simple-search', (req, res, next) ->
		res.render 'simple-search'

	app.get '/simple-search/link/:id(*)', (req, res, next) ->
		log.debug("ID to look for: #{req.params.id}")
		app.schemo.models.Entity.find(identifier:req.params.id)
			.exec (err, entities) ->
				return next err if err
				linkQuery = $or: []
				for entity in entities
					linkQuery.$or.push fromEntity: "#{entity.uri()}"
					linkQuery.$or.push toEntity: "#{entity.uri()}"
				RET = []
				app.schemo.models.EntityLink.find(linkQuery)
					.exec (err, links) ->
						return next err if err
						Async.each links, (link, linkDone) ->
							if not link.fromEntity or not link.toEntity
								return linkDone()
							app.schemo.models.Entity.findOne _id: link.fromEntity.substr(link.fromEntity.lastIndexOf('/') + 1)
								.exec (err, fromEntity) ->
									return linkDone err if err
									return linkDone() if not fromEntity
									app.schemo.models.Entity.findOne _id: link.toEntity.substr(link.toEntity.lastIndexOf('/') + 1)
										.exec (err, toEntity) ->
											return linkDone err if err
											return linkDone() if not toEntity
											RET.push [fromEntity.identifier, toEntity.identifier]
											return linkDone null
						, (err) ->
							return next err if err
							res.send RET

	done()
