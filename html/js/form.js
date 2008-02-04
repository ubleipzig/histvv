var formId = 'suchformular';
var helpSectionId = 'hilfe';
var helpBoxId = 'js-hilfe';

function initHelp () {
    var form = document.getElementById(formId);
    if(!form) return false;

    var helpSection = document.getElementById(helpSectionId);
    if(!helpSection) return false;
    helpSection.style.display = 'none';

    var helpBox = document.createElement('div');
    helpBox.setAttribute('id', helpBoxId);
    form.appendChild(helpBox);

    var links = form.getElementsByTagName('a');
    for (var i = 0; i < links.length; i++) {
        var a = links[i];
        var id = a.getAttribute('href').substr(1);

        a.onclick = function(e) {
            helpBox.style.display =
                helpBox.style.display == 'none' ? 'block' : 'none';
            return false;
        };

        a.onmouseover = function(e) {
            var id = this.getAttribute('href').substr(1);
            var help = document.getElementById(id);
            if(help) {
                if(helpBox.firstChild) helpBox.removeChild(helpBox.firstChild);
                helpContent = help.cloneNode(true);
                helpBox.appendChild(helpContent);
                helpBox.style.display = 'block';
            }
        };
    }
}

window.onload = initHelp;
