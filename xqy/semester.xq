declare default element namespace 'http://histvv.uni-leipzig.de/ns/2007';

declare variable $semester external := "Winter";
declare variable $jahr external := "1814";

for $d in /vv
let $k := $d/kopf
where $k/status[@komplett = "ja"]
  and $k/semester = $semester
  and $k/beginn/jahr = $jahr
return $d
