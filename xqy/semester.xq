declare default element namespace 'http://histvv.uni-leipzig.de/ns/2007';

declare variable $id external;

let $semester := if (substring($id, 5) = "w") then "Winter" else "Sommer"
let $jahr := substring($id, 1, 4)

for $d in /vv
let $k := $d/kopf
where $k/status[@komplett = "ja"]
  and $k/semester = $semester
  and $k/beginn/jahr = $jahr
return $d
