process.env.MONGO_PORT_27017_TCP_PORT or= 27018
process.env.MONGO_PORT_27017_TCP_ADDR or= 'localhost'
process.env.MONGO_DBNAME or= 'infolis-web'
process.env.INFOLINK_PORT_8080_TCP_ADDR or= 'localhost'
process.env.INFOLINK_PORT_8080_TCP_PORT or= 8080

module.exports =
	basePath: '/infolink'
	baseURI: 'http://infolis.gesis.org/infolink'
	site_api: 'http://infolis.gesis.org/infolink'
	site_github: 'http://infolis.github.io'
	backendURI: "http://#{process.env.INFOLINK_PORT_8080_TCP_ADDR}:#{process.env.INFOLINK_PORT_8080_TCP_PORT}"
	backendApiPath: 'infoLink-1.0/infolis-api'
	mongoURI: "mongodb://#{process.env.MONGO_PORT_27017_TCP_ADDR}:#{process.env.MONGO_PORT_27017_TCP_PORT}/#{process.env.MONGO_DBNAME}"
