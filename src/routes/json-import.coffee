{Form} = require 'multiparty'
Async  = require 'async'
Crypto = require 'crypto'
Fs     = require 'fs'
CONFIG = require '../config'
Request = require 'superagent'
isArray = require('util').isArray

log = require('../log')(module)

PUT_ORDER = [
	'entity'
	'queryService'
	'searchQuery'
	'searchResult'
	'infolisFile'
	'entityLink'
	'keyword'
	'textualReference'
	'infolisPattern'
	'execution'
]

_replaceAll = (db, oldId, newId) ->
	log.debug("_replaceAll: #{oldId} -> #{newId}")
	for resourceEndpoint in PUT_ORDER
		resMap = db[resourceEndpoint]
		continue unless resMap
		for resourceId of resMap
			for k,v of resMap[resourceId]
				if isArray v
					for i,vv of v
						if vv is oldId
							# log.silly "Replace in #{resourceId}.#{k}.#{i}"
							v[i] = newId
				else if v is oldId
					# log.silly "Replace in #{resourceId}.#{k}"
					resMap[resourceId][k] = newId
		if oldId of resMap
			resMap[newId] = resMap[oldId]
			delete resMap[oldId]

_postFiles = (db, files, callback) ->
	# return callback null
	missingFiles = []
	for fileId in Object.keys(db.infolisFile)
		if fileId not of files
			missingFiles.push fileId
	if missingFiles.length > 0
		return next "Did not provide these files: #{[missingFiles]}"
	# Post all files
	Async.eachLimit Object.keys(db.infolisFile), 10, (fileId, cb) ->
		log.silly files[fileId]
		filePath = files[fileId][0].path
		mediaType = if /.*txt$/.test(filePath) then 'text/plain' else 'application/pdf'
		Fs.readFile filePath, (err, fileData) ->
			return cb {filePath: filePath, infolisFile: db.infolisFile[fileId], err: err} if err
			sum = Crypto.createHash('md5')
			sum.update(fileData)
			md5 = sum.digest('hex')
			db.infolisFile[fileId].md5 = md5
			log.debug("Uploading '#{filePath}'(#{fileId}/#{md5}) to " +
				"#{CONFIG.backendURI}/#{CONFIG.backendApiPath}/upload/#{md5}")
			Request
				.put("#{CONFIG.backendURI}/#{CONFIG.backendApiPath}/upload/#{md5}")
				.type('application/octet-stream')
				.send(fileData)
				.end (err, res2) ->
					if err
						ret = new Error("Backend is down")
						ret.cause = err
						return cb ret
					if res2.status isnt 201
						ret = new Error(res.text)
						return cb ret
					log.info "Finished Upload #{md5}"
					return cb null, "Upload Finished"
	, (err) ->
		return callback err if err
		callback null

_postResource = (db, tags, resourceEndpoint, callback) ->
	resMap = db[resourceEndpoint]
	if not resMap
		return callback null
	log.debug "Posting #{Object.keys(resMap).length} things to #{resourceEndpoint}"
	mapping = {}
	Async.forEachOfLimit resMap, 100, (obj, resId, done) ->
		obj.tags or= []
		obj.tags.push tags
		# console.log obj
		log.debug "Putting to #{CONFIG.site_api}/api/#{resourceEndpoint}/#{resId}"
		Request
			.put "#{CONFIG.site_api}/api/#{resourceEndpoint}/#{resId}"
			.set 'content-type', 'application/json'
			.send obj
			.end (err, resp) ->
				if err
					log.error "ERROR Putting #{resId}", err
					return done err
				else if resp.status >= 400
					log.error "ERROR Putting #{resId}", resp.status
					return done err
				log.debug "<- #{resp.status} #{resp.header['location']}."
				_replaceAll db, resId, resp.header['location']
				return done()
	, (err) ->
		return callback err if err
		return callback null, db

module.exports = (app, done) ->

	app.swagger '/api/json-import',
		post:
			tags: ['advanced']
			summary: 'Import a database dump'
			responses:
				201:
					description: 'Successfully uploaded database'
			parameters: [
				{
					name: '--UUID-of-file--'
					description: 'File contents with their UUID as used in the db as the field name. Repeatable of course'
					type: 'file'
					in: 'formData'
				}
				{
					name: 'db'
					description: 'JSON dump'
					type: 'string'
					in: 'formData'
				}
			]

	app.post '/api/json-import', (req, res, next) ->
		form = new Form(
			maxFieldsSize: 100 * 1024 * 1024
			maxFields: 50 * 1000
		)
		timestamp = "#{Date.now()}"
		form.parse req, (err, fields, files) ->
			if err
				log.error err
				return next err
			if not fields.db
				return next "Must pass 'db'"
			db = JSON.parse fields.db.toString()
			_postFiles db, files, (err) ->
				return next err if err
				# replace ids
				for resourceEndpoint in PUT_ORDER
					log.info "Prepending #{timestamp} to all #{resourceEndpoint}"
					for resourceId of db[resourceEndpoint]
						_replaceAll db, resourceId, "#{timestamp}_#{resourceId}"
				log.silly "Tags to post", fields.tags.join(',')
				Async.eachSeries PUT_ORDER, (resourceEndpoint, cb) ->
					_postResource db, fields.tags.join(','), resourceEndpoint, (err) ->
						return cb err if err
						return cb null
				, (err) ->
					return next err if err
					# console.log JSON.stringify db, null, 2
					res.send db, null, 2

	done()
