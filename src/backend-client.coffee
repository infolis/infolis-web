Request = require 'superagent'
CONFIG = require './config'

module.exports = class BackendClient

	@uploadFile : (fileModel, buffer, cb) ->
		uploadURI = "#{CONFIG.backendURI}/upload/#{fileModel.md5}"
		Request
			.put(uploadURI)
			.send(buffer)
			.end (err, res) ->
				if err
					ret = new Error("Backend is down")
					ret.cause = err
					return cb ret
				if res.status isnt 201
					ret = new Error(res.text)
					return cb ret
				return cb()
