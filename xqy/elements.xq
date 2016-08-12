declare default element namespace "http://histvv.uni-leipzig.de/ns/2007";

declare variable $element-name external := "funktion";

let $werte := distinct-values(
  /vv[kopf/status/@komplett]//*[name(.)=$element-name]/normalize-space()
)

return
<report xmlns="">
  <element>{$element-name}</element>
  <werte>
  {
    for $w in $werte
    order by $w
    return
    <w>{$w}</w>
  }
  </werte>
</report>
