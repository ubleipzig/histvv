var tooltipId = 'verweis-tooltip';
var verweisTitlePrefix = 'Verweis auf: ';

$(document).ready(function(){

    var prefixOffset = verweisTitlePrefix.length

    var tooltip = document.createElement('div');
    tooltip.setAttribute('id', tooltipId);
    document.body.appendChild(tooltip);

    $("span.veranstaltungsverweis").hover(
        function() {
            var offset = $(this).offset();
            var id = this.getAttribute('title').substr(prefixOffset);
            var v = document.getElementById(id);
            if(!v) return false;
            tooltip.innerHTML = v.innerHTML;
            tooltip.style.left = offset.left + 'px';
            tooltip.style.top = offset.top + 'px';
            tooltip.style.display = 'block';
        },
        function() {
            tooltip.style.display = 'none';
        }
    );

});
