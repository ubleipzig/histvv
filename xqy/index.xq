declare namespace v = "http://histvv.uni-leipzig.de/ns/2007";

<index>
{
for $d in //v:vv
let $k := $d/v:kopf
let $sem := if ($k/v:semester = "Winter") then "w" else "s"
return
<vv name="{concat($k/v:beginn/v:jahr, $sem)}" >
  <titel>{concat($k/v:semester, "semester ", $k/v:beginn/v:jahr)}</titel>
  <vnum>{count($d//v:veranstaltung)}</vnum>
  {if ($k/v:status/@komplett = "ja") then <komplett/> else ''}
</vv>
}
</index>
