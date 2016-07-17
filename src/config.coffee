Merge = require 'merge'
HOSTNAME = require('os').hostname()

C = {}

C.mongoURI = 'mongodb://localhost:27018/infolis'
C.mongoServerOptions = {
	server:
		socketOptions:
			# The time in milliseconds to attempt a connection before timing out.
			connectTimeoutMS: 30000
}
C.backendURI   = 'http://localhost:8081'
C.backendStaticPath = 'static'
C.backendApiPath   = 'infoLink/infolis-api'
C.port         = 3000
# C.baseURI      = "http://www-test.bib.uni-mannheim.de/infolis/ws"
C.baseURI      = "http://localhost:#{C.port}"
C.apiPrefix    = '/api'
C.schemaPrefix = '/schema'
C.logdir = __dirname + '/../data/logs/'
C.logging      = {
	transports: [ 'console', 'file' ]
	level: 'debug'
	logdir: C.logdir
}
C.colorscheme = 'chrysoprase'
C.site_api = "http://infolis.gesis.org/infolink"
C.site_github = "http://infolis.github.io"

paths = []
if process.env.NODE_ENV is 'production'
	paths.push 'production'
else
	paths.push 'development'
paths.push HOSTNAME
for path in paths
	try
		console.log "Trying "  + __dirname + "/../config.#{path}"
		C = Merge C, require __dirname + "/../config.#{path}.coffee"
		console.log "Loaded configuration: #{path}"
	catch e
		console.log "No configuration found: #{path} (#{e})"


# context expansion must come last
C.expandContexts = ['basic', {
	# infolis: 'http://localhost:3000/schema/'
	# infolis: 'http://www-test.bib.uni-mannheim.de/infolis/schema/'
	infolis: "#{C.baseURI}#{C.schemaPrefix}/"
	bibo: 'http://purl.org/ontology/bibo/'
	dcterms: 'http://purl.org/dc/terms/'
	dqm: 'http://purl.org/dqm-vocabulary/v1/dqm#'
	omnom: 'http://onto.dm2e.eu/schema/omnom/'
	schema: 'http://schema.org/'
	doap: 'http://usefulinc.com/ns/doap#'
	vann: 'http://purl.org/vocab/vann/'
}]

module.exports = C
