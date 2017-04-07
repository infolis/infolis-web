class Demo2

	constructor: () ->
		
		$('#input-search').on 'click', () =>
			# Check 1: mandatory fields for search
			if @valtrimsplit("input-title")? and @valtrimsplit("input-title") 
				# Get Publications from Infolis
				$("#titlegrp").attr('class', 'col-md-5 has-success')
				@getpublications(@valtrimsplit("input-title"))
			else
				unless @valtrimsplit("input-title")? and @valtrimsplit("input-title")
					# Title -> Warning 
					#console.log "Warning"
					$("#titlegrp").attr('class', 'col-md-5 has-warning')
				else
					# Title -> OK
					$("#titlegrp").attr('class', 'col-md-5 has-success')

		$('#input-title').on 'keypress', () =>
			if(event.keyCode == 13)		
				# Check 1: mandatory fields for search
				if @valtrimsplit("input-title")? and @valtrimsplit("input-title") 
					# Get Publications from Infolis
					$("#titlegrp").attr('class', 'col-md-5 has-success')
					@getpublications(@valtrimsplit("input-title"))
				else
					unless @valtrimsplit("input-title")? and @valtrimsplit("input-title")
						# Title -> Warning 
						#console.log "Warning"
						$("#titlegrp").attr('class', 'col-md-5 has-warning')
					else
						# Title -> OK
						$("#titlegrp").attr('class', 'col-md-5 has-success')
					
	# Trim and split value
	valtrimsplit: (field) ->
		self = this
		unless field is undefined
			val = $("#"+field).val().trim()
		return val

	# Clear all:
	reset: () ->
		$(".toggleable").hide()
		
	hideallfields: () ->
		$("#masterform").css("display", "none")
		

	# Post entity to infolis:
	postpublication: (jsondata) ->
		$.ajax
			url: "http://infolis.gesis.org/test/api/entity"
			dataType: "json"
			type: "post"
			data: jsondata
			contentType: "application/json; charset=utf-8"
			error: (jqXHR, textStatus, errorThrown) ->
				#$('body').append "AJAX Error: #{textStatus}"
				console.log 'Adding publication error'
			success: (data, textStatus, jqXHR) ->
				#$('body').append "Successful AJAX call: #{data}"
				console.log 'Adding publication success: '
				console.log jsondata 
				@hideallfields()
	# Get Publications
	getpublications: (q) ->
		$("#searchresult").text("")
		self = this
		$.ajax
			url: "http://infolis.gesis.org/test/api/entity?q=name:" + encodeURIComponent(q)
			dataType: "json"
			type: "get"
			contentType: "application/json; charset=utf-8"
			error: (jqXHR, textStatus, errorThrown) ->
				console.log 'Get request error'
			success: (data, textStatus, jqXHR) ->
				urlp = "http://infolis.gesis.org/test/api/entity?q=name:" + encodeURIComponent(q)
				#console.log 'Get request success: '
				#console.log data['@graph'].length
				i = 0
				len = 0
				
				unless data['@graph'] is undefined
					len = data['@graph'].length 
					
				$("#searchresult").append('<tr><td></td><td><b>Anzahl:</b> ' + len + ' <b>q:</b> ' + urlp + '<br><br></td></tr>')
				$("#searchresult").append('<tr></tr>')
				$("#searchresult").append('<tr><td><b>Nr.</b></td><td><b>Titel:</b></td></tr>')
				unless data['@graph'] is undefined
					for k in data['@graph']
						#console.log k
						#console.log k['infolis:name']
						pubid = JSON.stringify(k['@id']).replace("http://infolis.gesis.org/test/api/entity/","").replace(/"/g,'')
						unless pubid is undefined
							#$("#searchresult").append("<tr><td>" + pubid + "</td></tr>")
							#build_str ='<tr><td><a id=view_"' + pubid + '" href="./publicationmask?id=' + pubid + '" title="' + pubid + '">' + k['infolis:name'] + '</a></td></tr>'
							#console.log build_str
							#$("#searchresult").append(build_str)
							$("#searchresult").append('<tr><td><center>' + i++ + '</center></td><td><a id=view_"' + pubid + '" href="./publicationmask?id=' + pubid + '" title="' + pubid + '" target="_new">' + k['infolis:name'] + '</a></td><td><a id="edit_' + pubid + '" type="submit" value="edit" href="./publicationmask?id=' + pubid + '" class="col-sm-10 form-control btn btn-warning">edit</a><div class="col-sm-1"></div><a id="input-search_' + pubid + '" type="submit" value="edit" href="./../api/entity/' + pubid + '" class="col-sm-10 form-control btn btn-success">view</a></td></tr>')
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
