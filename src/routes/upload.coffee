{Form}  = require 'multiparty'
Async = require 'async'
Crypto = require 'crypto'
Fs = require 'fs'

module.exports = setupRoutes = (app, opts) ->
	opts or= {}

	app.post '/upload', (req, res, next) ->
		form = new Form()
		form.parse req, (err, fields, files) ->
			if err
				throw new Error(err)

			fileField = files['file']?[0]

			if not fileField
				throw new Error("Didn't pass the 'file' upload")

			fileModel = new app.infolisSchema.models.File()

			Fs.readFile fileField.path, (err, fileData) ->
				Async.map ['md5', 'sha1'], (algo, done) ->
					sum = Crypto.createHash(algo)
					sum.update(fileData)
					fileModel.set algo, sum.digest('hex')
					done()
				, (err, result) -> 
					fileModel.set 'fileName', fileField.originalFileName
					fileModel.save (err, saved) ->
						if err
							throw new Error("Error saving file")
						res.redirect(fileModel.uri())
