Mongoose = require 'mongoose'

config = {}

config.mongoURI  or= 'mongodb://localhost:27018/test'
config.mongoServerOptions or= {
	server:
		socketOptions:
			# The time in milliseconds to attempt a connection before timing out.
			connectTimeoutMS: 5000
}
config.port          or= 3000
# config.baseURI       or= "http://localhost:#{config.port}"
# config.apiPrefix     or= '/api'
# config.schemaPrefix  or= '/schema'

module.exports = config
