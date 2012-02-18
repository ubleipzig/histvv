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

});
