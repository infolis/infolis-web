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
			.post("/infolink/api/upload")
			.type('form')
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

_postResource = (origDB, resourceEndpoint, callback) ->
	db = JSON.parse origDB
	mapping = {}
	Async.forEachOf db[resourceEndpoint], (obj, uuid, done) ->
		Request
			.post "/infolink/api/#{resourceEndpoint}"
			.send obj
			.end (err, resp) ->
				if err or resp.status isnt 201
					return done err
				mapping[uuid] = resp.get('Location')
				return done()
	, (err) ->
		return callback err if err
		return callback _replaceAll(origDB, mapping)

module.exports = (app, opts) ->

	opts or= {}

	app.post '/api/json-import', (req, res, next) =>
		form = new Form()
		form.parse req, (err, fields, files) =>
			if not fields.db
				return next "Must pass 'db'"
			_postFiles fields.db.toString(), files, (err, origDB) ->
				return next err if err
				# TODO
				# Here you are, Ethan
				order = ['pattern', 'execution']
				# Async.eachSeries order, (resourceEndpoint, done) ->
					# _postResource origDB, resourceEndpoint, done
				return res.send JSON.parse origDB
