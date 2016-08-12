declare namespace v = "http://histvv.uni-leipzig.de/ns/2007";

declare variable $name external := "Drobisch";

let $stellen := /v:vv[v:kopf/v:status/@komplett]
  //v:dozent[not(@ref) and normalize-space(v:nachname)=$name]

return
<report>
  <name>{$name}</name>
  <stellen >
  {
    for $d in $stellen
    let $node := $d/..
    let $s := $node/preceding::v:seite[1]
    let $snr := if ($s)
                then (if ($s/@nr) then $s/@nr else $s/string())
                else '1'
    let $kopf := $d/ancestor::v:vv/v:kopf
    let $sem := $kopf/v:semester/string()
    let $jahr := $kopf/v:beginn/v:jahr/string()
    return
    <stelle semester="{$sem}" jahr="{$jahr}" seite="{$snr}">
    {normalize-space($node)}
    </stelle>
  }
  </stellen>
</report>
