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

	_find_links_from_publication = (fromEntity, cb) ->
		FOUND_LINKS = []
		#
		# publication -> LINKPC
		#
		EntityLink.find({fromEntity: fromEntity.uri()}).limit(100).exec (err, links1) ->
			return cb err if err
			Async.eachSeries links1, (link, cbLinks1) ->
				#
				# LINKPC -> citedData
				#
				Entity.findOne {_id: _get_id link.toEntity}, (err, citedData) ->
					return cbLinks1 err if err or not citedData
					# TODO same_as
					# TODO same_as
					# TODO same_as
					#
					# citedData -> LINKCD
					#
					EntityLink.findOne {fromEntity: citedData.uri()}, (err, link2) ->
						return cbLinks1 err if err or not link2
						#
						# LINKCD -> dataset
						#
						Entity.findOne {_id: _get_id link2.toEntity}, (err, toEntity) ->
							return cbLinks1 err if err or not toEntity
							# jsonify and replace fromEntity/toEntity with populated documents
							toPush = link2.toJSON()
							toPush.fromEntity = fromEntity.toJSON()
							toPush.toEntity = toEntity.toJSON()
							FOUND_LINKS.push toPush
							return cbLinks1()
			, (err) ->
				return cb err if err
				return cb null, FOUND_LINKS

	_find_links = (needleQuery, cb) ->
		log.debug("Entity query:". needleQuery)
		FOUND_LINKS = []
		Entity.find(needleQuery).limit(1000).exec (err, entities) ->
			return cb err if err
			return cb null, [] if entities.length == 0
			Async.eachSeries entities, (fromEntity, cbEntities1) ->
				#
				# Query1 (publication -> dataset)
				#
				# log.debug "fromEntity", fromEntity.uri()
				if fromEntity.entityType is 'publication'
					_find_links_from_publication fromEntity, (err, links) ->
						return cbEntities1 err if err
						FOUND_LINKS.push x for x in links
						return cbEntities1()
			, (err) ->
				return cb err if err
				return cb null, FOUND_LINKS

	# Swagger interface
	app.get '/search', (req, res, next) ->
		locals = links: [], query: req.query
		if not req.query.id
			return res.render 'simple-search', locals
		req.query.id = _denoise_id(req.query.id)
		# Enable regex search with "?regex=on"
		if not req.query.regex
			needle = req.query.id
		else
			needle = '$regex': req.query.id
		needleQuery = $or: []
		needleQuery.$or.push _id: needle
		needleQuery.$or.push identifier: needle
		needleQuery.$or.push identifiers: needle
		needleQuery.entityType = req.query.from_type || 'publication'
		unless needleQuery.entityType in ['dataset', 'publication']
			return next "from_type must be dataset or publication"
		_find_links needleQuery, (err, links) ->
			if err
				next err
			else
				locals.links = links
				return res.render 'simple-search', locals

	done()
