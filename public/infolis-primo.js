function addinfolislinks() {
    var iconstyle = [
        'background-image: url(http://infolis.github.io/img/logo-circle.png) !important',
        'background-size: contain'
    ].join(';');
    $(".exltabheaderbuttonsendtolist").each(function(_, buttonlist) {
        var container = $(buttonlist).closest('.exlsummary');
        console.log(container);
        var query = 'title=' + encodeuricomponent($('.exllinkedfieldtitle', container).text());
        var doilabel = $('b:contains("doi")', container);
        if (doilabel[0]) query = 'id=' + encodeuricomponent(doilabel[0].nextsibling.textcontent.trim());
        $(".exlbuttonsendtoinfolis", buttonlist).remove();
        $(buttonlist).append($(`
          <li class="exlbuttonsendtoinfolis">
            <a href="http://infolis.gesis.org/search?${query}" target="blank">
            <span class="exlbuttonsendtolabel">in infolis suchen</span>
            <span class="exlbuttonsendtoicon" style='${iconstyle}'></span>
            </a>
          </li>`));
    });
}
function initializeinfolis() {
    $(document).ajaxcomplete(addinfolislinks);
    addinfolislinks();
}
initializeinfolis();
