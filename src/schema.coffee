### 
# Infolis Schema

###
TSON = require 'tson'

class InfolisSchemas

	constructor : (opts) ->
		opts or= {}
		@[k] = v for k,v of opts
		@pathToSchemology or= __dirname + '/../data/infolis.tson' 
		@schemology = TSON.load @pathToSchemology
		@ns = @schemology['@ns'] or {}
		if @schemology instanceof Error
			throw @schemology

		if not @dbConnection
			throw new Error("Need a DB Connection, provide 'dbConnection' to constructor")

		if not @mongooseJSONLD
			throw new Error("Must pass mongoose-jsonld instance 'mongooseJSONLD' to constructor")

		@schemas = {}
		@models = {}
		@onto = {
			'@context': {}
			'@graph': []
		}

		@_readSchemas()
		# @ontology = _readOntology(@schemology, @ns)
		# console.log @dbConnection.model

	_readSchemas : () ->
		for schemaName, schemaDef of @schemology
			if schemaName is '@ns'
				@onto['@context'][ns] = uri for ns,uri of schemaDef
			else if schemaName is '@context'
				# TODO add id
				@onto['@graph'].push schemaDef
			else
				schemaDef = JSON.parse JSON.stringify schemaDef
				# console.log schemaName
				# console.log schemaDef
				@schemas[schemaName] = @mongooseJSONLD.createSchema(schemaName, schemaDef, {strict: true})
				@models[schemaName] = @dbConnection.model(schemaName, @schemas[schemaName])
				@onto['@graph'].push @models[schemaName].jsonldTBox()

	jsonldTBox : (opts, cb) ->
		if typeof opts == 'function' then [cb, opts] = [opts, {}]
		if cb
			return @mongooseJSONLD._convert(@onto, opts, cb)
		else
			return @onto

module.exports = InfolisSchemas
