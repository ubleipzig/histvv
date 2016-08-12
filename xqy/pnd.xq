declare namespace v = "http://histvv.uni-leipzig.de/ns/2007";

declare variable $pnd external := "";

let $dozent := /v:dozentenliste/v:dozent[v:pnd=$pnd]

return
if ($dozent) then
<http>
  <location>/dozenten/{string($dozent/@xml:id)}.html</location>
</http>
else
()
