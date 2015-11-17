# $ = require 'jquery'
InfolinkClient = require './infolink-client.coffee'
if typeof window isnt 'undefined'
	exp = window
else if typeof self isnt 'undefined'
	exp = self
else
	exp = module.exports

exp.InfolinkClient = require './infolink-client.coffee'
