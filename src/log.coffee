InfolisLogging = require 'easylog'
CONFIG = require './config'
module.exports = (callingModule) ->
	InfolisLogging(callingModule, CONFIG.logging)
