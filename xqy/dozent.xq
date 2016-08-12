declare default element namespace "http://histvv.uni-leipzig.de/ns/2007";

declare variable $id external := "anger_r";

let $daten := /dozentenliste/dozent[@xml:id=$id]
let $veranstaltungen := /vv[kopf/status/@komplett]
  //veranstaltung[tokenize(@x-dozentenrefs, "\s+") = $id]

return
if ($daten) then
<report>
  {$daten}
  <stellen>
  {
    for $v in $veranstaltungen return
    <stelle semester="{$v/ancestor::vv/@x-semester}">
    {$v}
    {
     if ($v/dozent[@ref = $id])
     then ""
     else (if ($v/ders)
           then $v/ders/preceding::dozent[1]
           else $v/ancestor::veranstaltungsgruppe/dozent[@ref = $id][last()])
    }
    </stelle>
  }
  </stellen>
  <n>{count($veranstaltungen)}</n>
</report>
else
()
