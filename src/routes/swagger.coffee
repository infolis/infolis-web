module.exports = (app, opts) ->
	opts or= {}

	# swagger handler
	app.schemo.handlers.swagger.inject app, {
		basePath: "/infolink"
		info:
			title: 'Infolis YAY'
		paths:

			'/api/monitor':
				get:
					tags: ['custom', 'execution', 'monitor']
					description: 'Get the status of executions live from the backend'
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
					parameters: [
						{
							name: 'file'
							in: 'formData'
							type: 'file'
						}
						{
							name: 'mediaType'
							in: 'formData'
							schema:
								$ref: '#/definitions/InfolisFile/mediaType'
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
