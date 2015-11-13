module.exports = (app, opts) ->
	opts or= {}

	# swagger handler
	app.schemo.handlers.swagger.inject app, {
		basePath: "/infolink"
		info:
			title: 'Infolis YAY'
		paths:

			'/api/stats':
				get:
					tags: ['custom', 'monitor']
					description: 'Get some statistics about the data store'
					responses:
						200: description: "Retrieved the statistics"

			'/api/monitor':
				get:
					tags: ['custom', 'execution', 'monitor']
					description: 'Get the status of executions live from the backend'
					responses:
						200: description: "Retrieved the executions by status"
					parameters: [
						name: 'status'
						in: 'query'
						type: 'string'
						enum: [
							'PENDING'
							'STARTED'
							'FINISHED'
							'FAILED'
						]
					]

			'/api/upload':
				post:
					tags: ['custom', 'infolisFile']
					description: "Upload a file"
					consumes: ['multipart/form-data']
					parameters: [
						{
							name: 'file'
							type: 'file'
							in: 'formData'
						}
						{
							name: 'mediaType'
							type: 'string'
							in: 'formData'
							enum: [
								'application/pdf'
								'text/plain'
							]
						}
					]
					responses:
						201:
							description: 'File was uploaded'
							headers:
								'Location': {
									description: 'The location of the InfolisFile'
									type: 'string'
									format: 'uri'
								}
							schema:
								$ref: "#/definitions/InfolisFile"
						400:
							description: 'Upload failed'
						503:
							description: 'Backend is down.'
						503:
							description: 'Backend is down.'
						500:
							description: 'Backend failed.'

			'/api/execute':
				post:
					tags: ['custom', 'execution']
					description: "Post an execution and run it on the backend."
					consumes: ['application/json']
					parameters: [
						name: 'execution'
						in: "body"
						description: "Execution to POST"
						required: true
						schema:
							$ref: "#/definitions/Execution"
					]
					responses:
						201:
							description: 'Successfully started the execution'
							headers:
								'Location': {
									description: 'The location of the execution'
									type: 'string'
									format: 'uri'
								}
						400:
							description: 'Posting of the execution failed before execution. Verify it is valid by posting it directly.'
						500:
							description: 'Backend failed.'
	}
