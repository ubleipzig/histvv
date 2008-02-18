var formId = 'suchformular';
var helpSectionId = 'hilfe';

$(document).ready(function(){
    $('#'+helpSectionId).hide();
    $('#'+formId+' a').tooltip({
        bodyHandler: function() {
            return $($(this).attr('href')).html();
        },
        showURL: false
    });
});
