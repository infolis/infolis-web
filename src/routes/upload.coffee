{Form} = require 'multiparty'
Async  = require 'async'
Crypto = require 'crypto'
Fs     = require 'fs'
CONFIG = require '../config'
Request = require 'superagent'

module.exports = setupRoutes = (app, opts) ->
	opts or= {}

	app.post '/api/upload', (req, res, next) ->
		form = new Form()
		form.parse req, (err, fields, files) ->
			if err
				return next new Error(err)
			fileField = files['file']?[0]
			if not fileField
				ret = new Error("Didn't pass the 'file' upload")
				ret.cause = [fields, files]
				return next ret
			fileModel = new app.schemo.models.InfolisFile()
			Fs.readFile fileField.path, (err, fileData) ->
				Async.map ['md5', 'sha1'], (algo, done) ->
					sum = Crypto.createHash(algo)
					sum.update(fileData)
					fileModel.set algo, sum.digest('hex')
					done()
				, (err, result) ->
					fileModel.set 'size', fileField['size']
					fileModel.set 'mediaType', fields['mediaType']
					fileModel.set 'fileStatus', 'AVAILABLE'
					fileModel.set 'fileName', fileField['originalFilename']
					Request
						.put("#{CONFIG.backendURI}/upload/#{fileModel.md5}")
						.type('application/octet-stream')
						.send(fileData)
						.end (err, res2) ->
							if err
								ret = new Error("Backend is down")
								ret.cause = err
								return next ret
							if res2.status isnt 201
								ret = new Error(res.text)
								return next ret
							fileModel.save (err, saved) ->
								if err
									ret = new Error("Error saving file to database")
									ret.cause = err
									ret.status = 400
									return next ret
								res.status 201
								res.header 'Location', fileModel.uri()
								res.send '@link': fileModel.uri()
