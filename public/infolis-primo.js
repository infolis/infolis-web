function addInfolisLinks() {
	var iconStyle = [
		'background-image: url(http://infolis.github.io/img/logo-circle.png) !important',
		'background-size: contain'
	].join(';');
	$(".EXLTabHeaderButtonSendToList").each(function(_, buttonList) {
		var container = $(buttonList).closest('.EXLSummary');
		console.log(container);
		var query = 'title=' + encodeURIComponent($('.EXLLinkedFieldTitle', container).text());
		var doiLabel = $('b:contains("DOI")', container);
		if (doiLabel[0]) query = 'id=' + encodeURIComponent(doiLabel[0].nextSibling.textContent.trim());
		$(".EXLButtonSendToInfolis", buttonList).remove();
		$(buttonList).append($(`
		  <li class="EXLButtonSendToInfolis">
			<a href="http://infolis.gesis.org/search?${query}" target="blank">
			<span class="EXLButtonSendToLabel">In Infolis suchen</span>
			<span class="EXLButtonSendToIcon" style='${iconStyle}'></span>
			</a>
		  </li>`));
	});
}
function initializeInfolis() {
	$(document).ajaxComplete(addInfolisLinks);
	addInfolisLinks();
}

initializeInfolis();
