{Form} = require 'multiparty'
Async  = require 'async'
Crypto = require 'crypto'
Qs     = require 'qs'
Fs     = require 'fs'
CONFIG = require '../config'
Request = require 'superagent'

log = require('../log')(module)

module.exports = (app, done) ->

	app.swagger '/api/upload',
		post:
			tags: ['essential']
			summary: "Upload a file"
			description: "Upload a file and store it as an InfolisFile resource."
			consumes: ['multipart/form-data']
			parameters: [
				{
					name: 'file'
					required: true
					type: 'file'
					in: 'formData'
				}
				{
					name: 'identifier'
					type: 'string'
					in: 'formData'
				}
				{
					name: 'subjects'
					type: 'array'
					items: { type: 'string' }
					in: 'formData'
				}
				{
					name: 'authors'
					type: 'array'
					items: { type: 'string' }
					in: 'formData'
				}
				{
					name: 'language'
					type: 'string'
					in: 'formData'
					enum: [
						'en'
						'de'
					]
				}
				{
					name: 'name'
					type: 'string'
					in: 'formData'
				}
				{
					name: 'tags'
					type: 'array'
					items: { type: 'string' }
					in: 'formData'
				}
				{
					name: 'mediaType'
					type: 'string'
					required: true
					in: 'formData'
					enum: [
						'application/pdf'
						'text/plain'
					]
				}
			]
			responses:
				201:
					description: 'File was uploaded'
					headers:
						'Location': {
							description: 'The location of the InfolisFile'
							type: 'string'
							format: 'uri'
						}
					schema:
						$ref: "#/definitions/InfolisFile"
				400:
					description: 'Upload failed'
				503:
					description: 'Backend is down.'
				500:
					description: 'Backend failed.'

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
			entityModel = new app.schemo.models.Entity()
			fileModel = new app.schemo.models.InfolisFile()
			Fs.readFile fileField.path, (err, fileData) ->
				Async.each ['md5', 'sha1'], (algo, done) ->
					sum = Crypto.createHash(algo)
					sum.update(fileData)
					fileModel.set algo, sum.digest('hex')
					done()
				, (err) ->
					tags = []
					if fields['tags']
						tags = Qs.parse(fields['tags'][0]).tags
					entityModel.set 'tags', tags
					if fields['authors']
						entityModel.set 'authors', Qs.parse(fields['authors'][0]).authors
					if fields['subjects']
						entityModel.set 'subjects', Qs.parse(fields['subjects'][0]).subjects
					entityModel.set 'name', fields['name']
					entityModel.set 'identifier', fields['identifier']
					fileModel.set 'size', fileField['size']
					fileModel.set 'tags', tags
					fileModel.set 'mediaType', fields['mediaType']
					fileModel.set 'fileStatus', 'AVAILABLE'
					fileModel.set 'fileName', fileField['originalFilename']
					log.debug "Uploading File", fileModel.toJSON()
					Request
						.put("#{CONFIG.backendURI}/#{CONFIG.backendApiPath}/upload/#{fileModel.md5}")
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
							fileModel.save (err, savedFile) ->
								if err
									ret = new Error("Error saving file to database")
									ret.cause = err
									ret.status = 400
									return next ret
								entityModel.set 'file', savedFile
								entityModel.save (err, savedEntity) ->
									if err
										ret = new Error("Error saving entity to database")
										ret.cause = err
										ret.status = 400
										return next ret
									log.debug "Created entity: #{savedEntity}"
									res.status 201
									res.header 'Location', fileModel.uri()
									res.send '@link': fileModel.uri()

	done()
