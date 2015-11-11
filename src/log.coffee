InfolisLogging = require 'infolis-logging'
CONFIG = require './config'
module.exports = (callingModule) ->
	InfolisLogging(callingModule, CONFIG.logging)
