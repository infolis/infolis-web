layout = -> window.masonry.layout()

applyFilter = (input) ->
	unless input
		return
	if /^\s*$/.test input
		return
	[cls, panelClass] = input.split('/')
	resetFilter()
	$('.panel').removeClass('highlighted').removeClass('highlighted-child').hide()
	re = new RegExp('.*' + cls + '.*', 'i')
	$('[data-infolis-type]').each(->
		$this = $(this)
		toMatch = $this.attr('data-infolis-type')
		if toMatch and toMatch.match re
			if panelClass
				$this = $this.find("." + panelClass).first()
			expand($this)
			$this.parents('.panel').addClass('highlighted-child').show().each -> expand(@)
			$this.addClass('highlighted').show()
			$this.find('.panel').addClass('highlighted-child').show()
	)
	layout()
	# $(window).scrollTo(toHighlight)

resetFilter = (cls) ->
	$('.panel').removeClass('highlighted').removeClass('highlighted-child').show()
	collapseAll()

toggleCollapsed = () ->
	$panel = $(this).parent('.panel')
	if $panel.hasClass('panel-collapsed')
		expand $panel
	else
		collapse $panel

collapse = ($panel, skipLayout) ->
	$panel =  $($panel)
	$heading = $panel.find(".panel-heading").first()
	$panel.find('.panel-body').first().hide()
	$panel.addClass 'panel-collapsed'
	$heading.find('i').first().removeClass('glyphicon-chevron-up').addClass 'glyphicon-chevron-down'
	layout() unless skipLayout

expand = ($panel, skipLayout) ->
	$panel =  $($panel)
	$heading = $panel.find(".panel-heading").first()
	$panel.find('.panel-body').first().show()
	$panel.removeClass 'panel-collapsed'
	$heading.find('i').first().removeClass('glyphicon-chevron-down').addClass 'glyphicon-chevron-up'
	layout() unless skipLayout

collapseAll = ->
	$('.panel-default').each(->collapse($(@), true)).promise().done layout

expandAll = ->
	$('.panel-default').each(->expand($(@), true)).promise().done layout

clearFilter = ->
	$("#filter input").val('')
	window.location.hash = ''
	resetFilter()

$ ->
	$('.panel-heading').on 'click', toggleCollapsed
	$('#collapse-all').on 'click', collapseAll
	$('#expand-all').on 'click', expandAll
	$('.panel-heading').prepend $("<span class='pull-right'><i class='glyphicon glyphicon-chevron-up'/></span>")
	$("#filter input").on 'keyup', () -> applyFilter($(this).val())
	$(document).on 'keyup', (e) -> if e.keyCode == 27 then clearFilter()
	$("#filter-reset").on 'click', clearFilter
	window.masonry = new Masonry('.grid',
		columnWidth: '.grid-item'
		itemSelector: '.grid-item'
		transitionDuration: 0
		gutter: 0)
	collapseAll()
	$(window).on 'hashchange', ->
		fragment = location.hash
		if fragment
			applyFilter(fragment.substring(1))
	$(window).trigger 'hashchange'
