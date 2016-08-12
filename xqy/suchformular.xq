declare namespace v = "http://histvv.uni-leipzig.de/ns/2007";

let $fakultaeten := distinct-values(/v:vv//v:sachgruppe/@fakultät)

return
<formular>
  {
    for $vv in /v:vv
    let $name := concat($vv/@x-semester, "")
    let $titel := concat($vv/v:kopf/v:beginn/v:jahr, " ", $vv/v:kopf/v:semester)
    return
    <semester>
      <name>{$name}</name>
      <titel>{$titel}</titel>
    </semester>
  }
  <fakultäten>
  {
    for $f in $fakultaeten
    return
    <fakultät>{$f}</fakultät>
  }
  </fakultäten>
</formular>
