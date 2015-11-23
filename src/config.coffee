Merge = require 'merge'

C = {}

C.mongoURI = 'mongodb://localhost:27018/infolis'
C.mongoServerOptions = {
	server:
		socketOptions:
			# The time in milliseconds to attempt a connection before timing out.
			connectTimeoutMS: 5000
}
C.backendURI   = 'http://localhost:8081/infoLink/infolis-api'
C.port         = 3000
# C.baseURI      = "http://www-test.bib.uni-mannheim.de/infolis/ws"
C.baseURI      = "http://localhost:#{C.port}"
C.apiPrefix    = '/api'
C.schemaPrefix = '/schema'
C.logging      = {
	transports: [ 'console', 'file' ]
	level: 'debug'
	file:
		'filename': 'infolis-web.log'
		'logdir': __dirname + '/../data/logs/'
}
C.colorscheme = 'chrysoprase'
C.site_api = "http://infolis.gesis.org/infolink"
C.site_github = "http://infolis.github.io"

if process.env.NODE_ENV is 'production'
	path = __dirname + '/../config.prod'
else
	path = __dirname + '/../config.dev'

C = Merge C, require path
try
	console.log "Loaded configuration: #{path}"
catch
	console.log "No configuration found: #{path}"


# context expansion must come last
C.expandContexts = ['basic', {
	# infolis: 'http://localhost:3000/schema/'
	# infolis: 'http://www-test.bib.uni-mannheim.de/infolis/schema/'
	infolis: "#{C.baseURI}#{C.schemaPrefix}/"
	bibo: 'http://purl.org/ontology/bibo/'
	dc: 'http://purl.org/dc/elements/1.1/'
	dcterms: 'http://purl.org/dc/terms/'
	dm2e: 'http://onto.dm2e.eu/schema/dm2e/'
	dqm: 'http://purl.org/dqm-vocabulary/v1/dqm#'
	foaf: 'http://xmlns.com/foaf/0.1/'
	omnom: 'http://onto.dm2e.eu/schema/omnom/'
	owl: 'http://www.w3.org/2002/07/owl#'
	rdf: 'http://www.w3.org/1999/02/22-rdf-syntax-ns#'
	rdfs: 'http://www.w3.org/2000/01/rdf-schema#'
	schema: 'http://schema.org/'
	science: 'http://semanticscience.org/resource/'
	skos: 'http://www.w3.org/2004/02/skos/core#'
	uri4uri: 'http://uri4uri.net/vocab#'
	xsd: 'http://www.w3.org/2001/XMLSchema#'
}]

module.exports = C
