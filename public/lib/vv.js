if (typeof google != 'undefined')
    google.load('visualization', '1', {packages: ['corechart']});

$(document).ready(function(){

    // We currently use the id attribute of the span to propagate the
    // ID the 'veranstaltungsverweis' is referring to. To prevent ID
    // conflicts in the HTML we prefix it with an underscore. This is
    // kind of ugly and could be avoided by using the title attribute
    // instead. Question is, how can we access the original title from
    // the bodyHandler function.
    var idPrefix = '_';

    $('span[id].veranstaltungsverweis').tooltip({
        bodyHandler: function() {
            var id = this.getAttribute('id').substr(idPrefix.length);
            return $(document.getElementById(id)).html();
        },
        // top and left are a workaround for the positioning issues
        // probably due to the relative (i.e. non-pixel) measurements
        // used in the css
        top: 10,
        left: 10
    });

    // suppress native title tooltips when hovering over span.anmerkung
    $('span.anmerkung').hover(
        function() {
            var v = $(this).parents('.veranstaltung');
            v.attr('_title', v.attr('title'));
            v.removeAttr('title');
        },
        function() {
            var v = $(this).parents('.veranstaltung');
            v.attr('title', v.attr('_title'));
            v.removeAttr('_title');
        }
    );

    $('span.anmerkung').tooltip({
        bodyHandler: function() {
            return $(this.getElementsByTagName('span')[0]).html();
        }
    });

    var toc = $('#content ol.toc');
    if (toc.length > 0) list2chart(toc);

});

function list2chart (list) {
    if (typeof google == 'undefined') return false;

    var vvChartID = 'vvchart';

    if ($('#' + vvChartID).length == 0) {
        var div = document.createElement('div');
        $(div).insertAfter(list);
        $(div).attr('id', vvChartID);
    }

    var chartDiv = $('#' + vvChartID);

    if (chartDiv.find('.title').length == 0) {
        var title = document.createElement('h3');
        $(title).addClass('title');
        $(title).text('Veranstaltungen pro Semester');
        div.appendChild(title);
    }

    if (chartDiv.find('.bar').length == 0) {
        for (var i = 0; i < 3; i++) {
            var bar = document.createElement('span');
            $(bar).addClass('bar').text('x');
            div.appendChild(bar);
        }
    }

    var colors = new Array();
    chartDiv.find('.bar').each(function(index){
        colors.push( $(this).css('color') );
    });
    var size = chartDiv.css('font-size').replace(/px$/, '');
    var title = chartDiv.find('.title').text();
    var titleColor = chartDiv.find('.title').css('color');
    var titleFont = chartDiv.find('.title').css('font-family');
    var titleSize = chartDiv.find('.title').css('font-size').replace(/px$/, '');

    var settings = {
        title: title,
        colors: colors,
        fontSize: size,
        titleTextStyle: {
            color: titleColor,
            fontName: titleFont,
            fontSize: titleSize
        },
        width: 750,
        height: 300,
        chartArea: {left: 40, top: 40},
        legend: {position: 'none'}
    };

    var items = list.find('li');

    var data = new google.visualization.DataTable();
    data.addColumn('string','Semester');
    data.addColumn('number','Veranstaltungen');
    data.addRows(items.length);

    items.each(function(index){
        var label = $(this).find('a').text()
            .replace(/^Sommersemester/, "SS")
            .replace(/^Wintersemester/, "WS");
        var n = parseFloat($(this).find('span').text().replace(/[()]/g, ''));
        data.setCell(index, 0, label);
        data.setCell(index, 1, n);
        if(index > 1) return;
    });

    var chart = new google.visualization.ColumnChart(
        document.getElementById(vvChartID)
    );
    chart.draw(data, settings);
}
