CONFIG = require '../config'
Async  = require 'async'
log = require('../log')(module)

_denoise_id = (s) ->
	sold = s
	s = s.replace(/doi:/i, '')
	s = s.replace(new RegExp("https?://(dx\\.)?doi.org/?"), '')
	log.debug("_denoise_id: #{sold} -> #{s}")
	return s

_get_id = (s) ->
	snew = s.substr(s.lastIndexOf('/') + 1)
	log.debug("_get_id: #{s} -> #{snew}")
	return snew

module.exports = (app, done) ->

	_find_links = (needleQuery, cb) ->
		log.debug("Entity query: #{needleQuery}")
		{Entity, EntityLink} = app.schemo.models
		Entity.find(needleQuery).limit(100)
			.exec (err, entities) ->
				return cb err if err
				return cb null, [] if entities.length == 0
				linkQuery = $or: []
				for tofrom in ['to', 'from']
					for entity in entities
						linkQuery.$or.push "#{tofrom}Entity": "#{entity.uri()}"
				log.debug("Link query: ", linkQuery)
				EntityLink.find(linkQuery).limit(100).exec (err, links) ->
					return cb err if err
					log.debug("Links:", x.uri() for x in links)
					Async.map links, (link, linkDone) ->
						link = link.toJSON()
						return linkDone "Bad link" if not link.fromEntity or not link.toEntity
						Async.each ['from', 'to'], (tofrom, tofromDone) ->
							Entity.findOne(_id: _get_id(link["#{tofrom}Entity"])).exec (err, tofromEntity) ->
								return tofromDone "Error" + err if err or not tofromEntity
								link["#{tofrom}Entity"] = tofromEntity.toJSON()
								return tofromDone()
						, (err) ->
							return linkDone err, link
					, (err, newLinks) ->
						return cb err if err
						log.debug(newLinks)
						cb null, newLinks

	# Swagger interface
	app.get '/search', (req, res, next) ->
		locals = links: [], query: req.query
		if not req.query.id
			return res.render 'simple-search', locals
		req.query.id = _denoise_id(req.query.id)
		if not req.query.regex
			needle = req.query.id
		else
			needle = '$regex': req.query.id
		needleQuery = $or: []
		needleQuery.$or.push _id: needle
		needleQuery.$or.push identifier: needle
		needleQuery.$or.push identifiers: needle
		_find_links needleQuery, (err, links) ->
			if err
				next err
			else
				locals.links = links
				return res.render 'simple-search', locals

	done()
