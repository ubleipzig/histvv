declare namespace v = "http://histvv.uni-leipzig.de/ns/2007";

declare variable $element-name := "modus";
declare variable $element-content := "publice";

let $stellen := /v:vv[v:kopf/v:status/@komplett]
  //*[name(.)=$element-name and normalize-space(.)=$element-content]

let $n := count($stellen)

return
<report>
  <element>{$element-name}</element>
  <value>{$element-content}</value>
  <n>{$n}</n>
  <stellen>
  {
    for $d in $stellen
    let $node := $d/..
    let $s := if ($n < 100)
      then $node/preceding::v:seite[1]
      else ()
    let $snr := if ($s)
                then (if ($s/@nr) then $s/@nr else $s/string())
                else '0'
    let $kopf := $d/ancestor::v:vv/v:kopf
    let $sem := $kopf/v:semester/string()
    let $jahr := $kopf/v:beginn/v:jahr/string()
    return
    <stelle semester="{$sem}" jahr="{$jahr}" seite="{$snr}">
    {$node}
    </stelle>
  }
  </stellen>
</report>
