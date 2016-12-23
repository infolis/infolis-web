CONFIG = require '../config'
Async  = require 'async'
log = require('../log')(module)
Accepts    = require 'accepts'

_denoise_id = (s) ->
	sold = s
	s = s.replace(/doi:/i, '')
	s = s.replace(new RegExp("https?://(dx\\.)?doi.org/?"), '')
	# log.debug("_denoise_id: #{sold} -> #{s}")
	return s

_get_id = (s) ->
	snew = s.substr(s.lastIndexOf('/') + 1)
	# log.debug("_get_id: #{s} -> #{snew}")
	return snew

#publication -> entityLink -> dataset
#publication -> entityLink -> citedData -> entityLink -> dataset
#

# dataset -> publication
# ignore entities of type dataset

#        (refererences)  (xy_temporal)
#           LINKPC1        LINKCD
#        from|    |to  from|    |to
#            v    v        v    v
# publication1    citedData1    dataset1
#                     ^
#                   to|from
#                   LINKSA (same_as)
#                 from|to
#                     v
# publication2    citedData2
#            ^    ^
#        from|    |to
#            LINKPC2
#         (references)
#
# Query#1: id for dataset1 -> LINKCD, possibly LINKSA (citedData1/2), LINKPC1 -> publication
# Query#2: id for publication1 -> LINKCD, possibly same_as

module.exports = (app, done) ->
	{Entity, EntityLink} = app.schemo.models

	_find_links_to_dataset = (toEntity, limit, cb) ->
		FOUND_LINKS = []
		EntityLink.find({toEntity: toEntity.uri()}).limit(limit).exec (err, links1) ->
			return cb err if err
			Async.eachLimit links1, 100, (link, cbLinks1) ->
				Entity.findOne {_id: _get_id link.fromEntity}, (err, citedData) ->
					return cbLinks1 err if err or not citedData
					EntityLink.findOne {toEntity: citedData.uri()}, (err, link2) ->
						return cbLinks1 err if err or not link2
						Entity.findOne {_id: _get_id link2.fromEntity}, (err, fromEntity) ->
							return cbLinks1 err if err or not fromEntity
							if fromEntity.entityType is 'publication'
								toPush = link2.toJSON()
								toPush.fromEntity = fromEntity.toJSON()
								toPush.toEntity = toEntity.toJSON()
								FOUND_LINKS.push toPush
							return cbLinks1()
			, (err) ->
				return cb err if err
				return cb null, FOUND_LINKS

	_find_links_from_publication = (fromEntity, limit, cb) ->
		FOUND_LINKS = []
		EntityLink.find({fromEntity: fromEntity.uri()}).limit(limit).exec (err, links1) ->
			return cb err if err
			# publication -> LINKPC
			Async.eachSeries links1, (link, cbLinks1) ->
				# LINKPC -> citedData
				Entity.findOne {_id: _get_id link.toEntity}, (err, citedData) ->
					return cbLinks1 err if err or not citedData
					# citedData -> LINKCD
					# TODO same_as
					EntityLink.findOne {fromEntity: citedData.uri()}, (err, link2) ->
						return cbLinks1 err if err or not link2
						console.log(link.entityRelations)
						console.log(link2.entityRelations)
						# LINKCD -> dataset
						Entity.findOne {_id: _get_id link2.toEntity}, (err, toEntity) ->
							return cbLinks1 err if err or not toEntity
							# jsonify and replace fromEntity/toEntity with populated documents
							toPush = link2.toJSON()
							# toPush.confidence = (link.confidence || -1)
							toPush.fromEntity = fromEntity.toJSON()
							toPush.toEntity = toEntity.toJSON()
							FOUND_LINKS.push toPush
							return cbLinks1()
			, (err) ->
				return cb err if err
				return cb null, FOUND_LINKS

	_find_links = (needleQuery, limit, cb) ->
		log.debug("Entity query:". needleQuery)
		FOUND_LINKS = []
		Entity.find(needleQuery).limit(limit).exec (err, entities) ->
			return cb err if err
			return cb null, [] if entities.length == 0
			Async.eachSeries entities, (needleEntity, cbEntities1) ->
				#
				# Query1 (publication -> dataset)
				#
				# log.debug "needleEntity", needleEntity.uri()
				if needleEntity.entityType is 'publication'
					_find_links_from_publication needleEntity, limit, (err, links) ->
						return cbEntities1 err if err
						FOUND_LINKS.push x for x in links
						return cbEntities1()
				else
					_find_links_to_dataset needleEntity, limit, (err, links) ->
						return cbEntities1 err if err
						FOUND_LINKS.push x for x in links
						return cbEntities1()
			, (err) ->
				return cb err if err
				return cb null, FOUND_LINKS

	app.get '/search', (req, res, next) ->
		locals = links: [], query: req.query
		if not req.query.id and not req.query.title
			return res.render 'simple-search', locals
		needleQuery = $or: []
		if req.query.id
			req.query.id = _denoise_id(req.query.id)
			# Enable regex search with "?regex=on"
			if not req.query.regex
				needle = req.query.id
			else
				needle = '$regex': req.query.id
			needleQuery.$or.push _id: needle
			needleQuery.$or.push identifier: needle
			needleQuery.$or.push identifiers: needle
		if req.query.title
			needleQuery.$or.push name: '$regex': req.query.title
		needleQuery.entityType = req.query.type || 'publication'
		unless needleQuery.entityType in ['dataset', 'publication']
			return next "type must be dataset or publication"
		limit = parseInt(req.query.limit or 1000)
		_find_links needleQuery, limit, (err, links) ->
			return next err if err
			if Accepts(req).type('text/html')
				locals.links = links
				return res.render 'simple-search', locals
			else
				return res.send links

	done()
