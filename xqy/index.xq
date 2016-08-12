declare default element namespace "http://histvv.uni-leipzig.de/ns/2007";

<index>
{
for $d in //vv
let $k := $d/kopf
let $sem := if ($k/semester = "Winter") then "w" else "s"
return
<vv name="{concat($k/beginn/jahr, $sem)}" >
  <titel>{concat($k/semester, "semester ", $k/beginn/jahr)}</titel>
  <vnum>{count($d//veranstaltung)}</vnum>
  {if ($k/status/@komplett = "ja") then <komplett/> else ''}
</vv>
}
</index>
