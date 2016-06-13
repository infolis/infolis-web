{Form} = require 'multiparty'
Async  = require 'async'
Crypto = require 'crypto'
Fs     = require 'fs'
CONFIG = require '../config'
Request = require 'superagent'


_replaceAll = (str, mapping) ->
	for olds, news of mapping
		str = str.replace(new RegExp(olds, 'g'), news)
	return str

_postFiles = (origDB, files, callback) ->
	db = JSON.parse origDB
	missingFiles = []
	for fileId in Object.keys(db.infolisFile)
		if fileId not of files
			missingFiles.push fileId
	if missingFiles.length > 0
		return next "Did not provide these files: #{[missingFiles]}"
	# Post all files
	mapping = {}
	Async.each Object.keys(db.infolisFile), (fileId, done) ->
		filePath = files[fileId][0].path
		mediaType = if /.*txt$/.test(filePath) then 'text/plain' else 'application/pdf'
		Request
			.post("#{CONFIG.baseURI}/api/upload")
			.type('form')
			.field('tags', db.infolisFile[fileId].tags.join(','))
			.field('mediaType', mediaType)
			.attach('file', filePath)
			.buffer(false)
			.end (err, resp) ->
				if resp.status isnt 201
					console.log resp
					err = resp.text
				if err
					console.log err
					done err
				mapping[fileId] = resp.get('Location')
				done()
	, (err) ->
		if err
			callback err
		callback null, _replaceAll(origDB, mapping)

_postResource = (origDB, tags, resourceEndpoint, callback) ->
	db = JSON.parse origDB
	resMap = db[resourceEndpoint]
	if not resMap
		return callback null, origDB
	console.log "Posting #{Object.keys(resMap).length} to #{resourceEndpoint}"
	mapping = {}
	Async.forEachOf resMap, (obj, uuid, done) ->
		obj.tags or= []
		obj.tags.push tags
		console.log obj
		Request
			.post "/api/#{resourceEndpoint}"
			.set 'content-type', 'application/json'
			.send obj
			.end (err, resp) ->
				# console.log resp
				if err or resp.status > 400
					console.error "ERROR", resp.status
					return done err
				mapping[uuid] = resp.get('location')
				# console.log "headers", resp.body
				console.log "Posted #{uuid} as #{mapping[uuid]}"
				return done()
	, (err) ->
		return callback err if err
		return callback null, _replaceAll(origDB, mapping)

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
		form = new Form()
		form.parse req, (err, fields, files) ->
			if not fields.db
				return next "Must pass 'db'"
			_postFiles fields.db.toString(), files, (err, serializedDB) ->
				return next err if err
				order = [
					'queryService'
					'searchQuery'
					'searchResult'
					'entity'
					'entityLink'
					'keyword'
					'textualReference'
					'infolisPattern'
					'execution'
				]
				Async.eachSeries order, (resourceEndpoint, done) ->
					console.log "Tags to post", fields.tags.join(',')
					_postResource serializedDB, fields.tags.join(','), resourceEndpoint, (err, updatedSerializedDB) ->
						return done err if err
						serializedDB = updatedSerializedDB
						done()
				, (err) ->
					return next err if err
					return res.send JSON.stringify JSON.parse(serializedDB), null, 2

	done()
