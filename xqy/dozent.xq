declare namespace v = "http://histvv.uni-leipzig.de/ns/2007";

declare variable $id external := "anger_r";

let $daten := /v:dozentenliste/v:dozent[@xml:id=$id]
let $veranstaltungen := /v:vv[v:kopf/v:status/@komplett]
  //v:veranstaltung[tokenize(@x-dozentenrefs, "\s+") = $id]

return
if ($daten) then
<report>
  {$daten}
  <stellen>
  {
    for $v in $veranstaltungen return
    <stelle semester="{$v/ancestor::v:vv/@x-semester}">
    {$v}
    {
     if ($v/v:dozent[@ref = $id])
     then ""
     else (if ($v/v:ders)
           then $v/v:ders/preceding::v:dozent[1]
           else $v/ancestor::v:veranstaltungsgruppe/v:dozent[@ref = $id][last()])
    }
    </stelle>
  }
  </stellen>
  <n>{count($veranstaltungen)}</n>
</report>
else
()
