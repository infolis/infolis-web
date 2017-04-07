class Demo2

	constructor: () ->
		id = decodeURIComponent( v.split( "=" )[1] ) if decodeURIComponent( v.split( "=" )[0] ) == name for v in window.location.search.substring( 1 ).split( "&" )
		
		# Display Add or Update Button!
		if not id? or id is 'undefined'
			$("#publication-update").attr('Style', 'display:none')
		else
			$("#publication-add").attr('Style', 'display:none')
			# Get Parameres for the Form:
			@getpublication_and_fill_fields(id)

		# Onclick ADD:
		$('#publication-add').on 'click', () =>
			# Check 1: mandatory fields set? 
			if @valtrimsplit("title")? and @valtrimsplit("title") and @valtrimsplit("journal")? and @valtrimsplit("journal") and @valtrimsplit("year")? and @valtrimsplit("year")
				# TODO check 2: is allrdy in DB? 
				# Put all data in a object: 
				dataobj ={"publicationType" : @valtrimsplit("pubtype"),"publicationStatus" : @valtrimsplit("pubstatus"),"name" : @valtrimsplit("title"), "view" : @valtrimsplit("citation"),"journalTitle" : @valtrimsplit("journal"), "volume" : @valtrimsplit("volume"),"number" : @valtrimsplit("number"), "year" : @valtrimsplit("year"),"month" : @valtrimsplit("month"), "pages" : @valtrimsplit("pages"),"issn" : @valtrimsplit("issn"), "url" : @valtrimsplit("url"),"identifiers" : @valtrimsplit("doi"), "abstracttext" : @valtrimsplit("abstract"),"subjects" : @valtrimsplit("keywords"), "classification" : @valtrimsplit("classification"),"authors" : @valtrimsplit("authors"), "editors" : @valtrimsplit("editors")}
				# Set values to JSON 
				datajson = JSON.stringify(dataobj)
				# Post to Infolis
				@postpublication_add(datajson)
			else
				unless @valtrimsplit("title")? and @valtrimsplit("title")
					# Title -> Warning 
					$("#titlegrp").attr('class', 'col-md-4 has-warning')
				else
					# Title -> OK
					$("#titlegrp").attr('class', 'col-md-4 has-success')
				unless @valtrimsplit("journal")? and @valtrimsplit("journal")
					# Journal -> Warning 
					$("#journalgrp").attr('class', 'col-md-4 has-warning')
				else
					# Journal -> OK 
					$("#journalgrp").attr('class', 'col-md-4 has-success')
				unless @valtrimsplit("year")? and @valtrimsplit("year")
					# Year -> Warning
					$("#yeargrp").attr('class', 'col-md-4 has-warning')
				else
					# Year -> OK
					$("#yeargrp").attr('class', 'col-md-4 has-success')
		
		# Onclick UPDATE --> ID !!! TODO
		$('#publication-update').on 'click', () =>
			# Check 1: mandatory fields set? 
			if @valtrimsplit("title")? and @valtrimsplit("title") and @valtrimsplit("journal")? and @valtrimsplit("journal") and @valtrimsplit("year")? and @valtrimsplit("year")
				# TODO check 2: is allrdy in DB? 
				# Put all data in a object: 
				dataobj ={"publicationType" : @valtrimsplit("pubtype"),"publicationStatus" : @valtrimsplit("pubstatus"),"name" : @valtrimsplit("title"), "view" : @valtrimsplit("citation"),"journalTitle" : @valtrimsplit("journal"), "volume" : @valtrimsplit("volume"),"number" : @valtrimsplit("number"), "year" : @valtrimsplit("year"),"month" : @valtrimsplit("month"), "pages" : @valtrimsplit("pages"),"issn" : @valtrimsplit("issn"), "url" : @valtrimsplit("url"),"identifiers" : @valtrimsplit("doi"), "abstractText" : @valtrimsplit("abstract"),"subjects" : @valtrimsplit("keywords"), "classification" : @valtrimsplit("classification"),"authors" : @valtrimsplit("authors"), "editors" : @valtrimsplit("editors")}
				# Set values to JSON 
				datajson = JSON.stringify(dataobj)
				# Post to Infolis
				@postpublication_update(id,datajson)
			else
				unless @valtrimsplit("title")? and @valtrimsplit("title")
					# Title -> Warning 
					$("#titlegrp").attr('class', 'col-md-4 has-warning')
				else
					# Title -> OK
					$("#titlegrp").attr('class', 'col-md-4 has-success')
				unless @valtrimsplit("journal")? and @valtrimsplit("journal")
					# Journal -> Warning 
					$("#journalgrp").attr('class', 'col-md-4 has-warning')
				else
					# Journal -> OK 
					$("#journalgrp").attr('class', 'col-md-4 has-success')
				unless @valtrimsplit("year")? and @valtrimsplit("year")
					# Year -> Warning
					$("#yeargrp").attr('class', 'col-md-4 has-warning')
				else
					# Year -> OK
					$("#yeargrp").attr('class', 'col-md-4 has-success')
					
		$('#publication-cancel').on 'click', () =>
			@hideallfields()
				

	# Trim and split value
	valtrimsplit: (field) ->
		self = this
		unless field is undefined
			val = $("#"+field).val().trim().split(/\s*,\s*/)
		return val[0]

	# Clear all:
	reset: () ->
		$(".toggleable").hide()
		
	hideallfields: () ->
		$("#masterform").css("display", "none")
		

	# Post entity to infolis:
	postpublication_add: (jsondata) ->
		$.ajax
			url: "http://infolis.gesis.org/test/api/entity"
			dataType: "json"
			type: "post"
			data: jsondata
			contentType: "application/json; charset=utf-8"
			error: (jqXHR, textStatus, errorThrown) ->
				console.log 'Adding publication error'
				console.log textStatus
			success: (data, textStatus, jqXHR) ->
				console.log 'Adding publication success: '
				console.log jsondata 
				@hideallfields()

	# Post entity to infolis: TODO: Update!!
	postpublication_update: (id, jsondata) ->
		$.ajax
			url: "http://infolis.gesis.org/test/api/entity/" + id
			dataType: "json"
			type: "put"
			data: jsondata
			contentType: "application/json; charset=utf-8"
			error: (jqXHR, textStatus, errorThrown) ->
				console.log 'Updating publication error'
				console.log textStatus
				console.log jsondata
				console.log errorThrown
			success: (data, textStatus, jqXHR) ->
				console.log 'Updateing publication success'
				console.log jsondata 
				@hideallfields()

				
	# Get Parameter from infolis:
	getpublication_and_fill_fields: (id) ->		
		self = this
		$.ajax
			url: "http://infolis.gesis.org/test/api/entity/"+id
			type: "get"
			contentType: "application/json; charset=utf-8"
			error: (jqXHR, textStatus, errorThrown) ->
				console.log 'getting publication error'
			success: (data, textStatus, jqXHR) ->
				console.log 'Getting publication success'
				$("#pubtype").val(jqXHR.responseJSON.publicationType)						# OK 
				$("#pubstatus").val(jqXHR.responseJSON.publicationStatus)					# OK
				$("#title").attr({value:jqXHR.responseJSON.name}) 							# OK
				$("#citation").attr({value:jqXHR.responseJSON.view})						# ?Gibt es das Feld view?
				$("#journal").attr({value:jqXHR.responseJSON.journalTitle})					# OK
				$("#volume").attr({value:jqXHR.responseJSON.volume})						# OK
				$("#number").attr({value:jqXHR.responseJSON.number})						# OK
				$("#year").attr({value:jqXHR.responseJSON.year})							# OK
				$("#month").val(jqXHR.responseJSON.month)									# OK aber nur die Select version! (TODO)
				$("#pages").attr({value:jqXHR.responseJSON.pages})							# OK
				$("#issn").attr({value:jqXHR.responseJSON.issn})							# OK
				$("#url").attr({value:jqXHR.responseJSON.url})								# OK
				$("#doi").attr({value:jqXHR.responseJSON.identifiers}) 						# A;B;C
				$("#abstract").val(jqXHR.responseJSON.abstractText)							# OK
				$("#keywords").attr({value:jqXHR.responseJSON.subjects})					# A;B;C
				$("#classification").attr({value:jqXHR.responseJSON.classification})		# A;B;C
				$("#authors").val(jqXHR.responseJSON.authors)								# A;B;C
				$("#editors").val(jqXHR.responseJSON.editors)								# A;B;C
				
	# Fill all Fields:
	fielfields: (obj) ->
		console.log obj.name
		$("#title").attr({value:obj.name})
		
$ ->
	demo2 = new Demo2()

# publication -> publicationType(string)
# publicationstatus -> publiationStatus (string)
# Title -> name (string)
# citation -> view (string)
# journal -> journalTitle (string)
# volume -> volume (string)
# Number -> number (string)
# Year -> year (string)
# month -> month (string)
# Pages -> pages (string)
# issn -> issn (string) und auch identifiers (List<String>)
# url -> url (string)
# doi -> identifiers (List<String>)
# abstract -> abstractText (string)
# keywords -> subjects (List<String>)
# classification -> classification
# authors -> authors (List<String>)
# editors -> editors (List<String>)
# --------------
# language (string)
# publisher (string)
# isbn (das gleiche wie bei issn)
# identifiers (List<String>)
# location (string)
