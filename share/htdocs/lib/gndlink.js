$(document).ready(function(){
    if (gndlinkPndPara && gndlinkURL) {
        var pnd = $(gndlinkPndPara + ' a').text();
        if (pnd != '') gndlinks(pnd);
    }
});

function gndlinks (pnd) {
    url = gndlinkURL + pnd + '.json';

    $.getJSON(url, function (data) {
        if (!$.isArray(data)) return false;
        if (data.length === 0) return false;

        var links = new Array();
        var list = $('#content.dozent ul.links');

        if (list.length == 0) {
            var p = $(gndlinkPndPara);
            p.after('<ul class="links"></ul>');
            p.after('<h3>Links</h3>');
            list = $('#content.dozent ul.links');
        }

        list.find('li').each(function(index) {
            var text = $.trim( $(this).text() ).replace(/\s\s+/g, ' ');
            links.push( text );
        });

        for (var i in data) {
            if ($.inArray(data[i]['label'], links) >= 0) continue;
            list.append(
                '<li><a href="' + data[i]['url'] + '">'
                    + data[i]['label'] + '</a></li>' );
        }
    });
}
