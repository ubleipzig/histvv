declare namespace v = "http://histvv.uni-leipzig.de/ns/2007";

let $namen := collection("histvv.dbxml")/v:vv[v:kopf/v:status/@komplett]
                         //v:dozent[not(@ref)]
                          /v:nachname[not(v:seite)]/normalize-space()

let $neu := for $n in distinct-values($namen)
            return
            <dozent xmlns="http://histvv.uni-leipzig.de/ns/2007">
              <name><nachname>{$n}</nachname></name>
            </dozent>

let $alt := collection("histvv.dbxml")/v:dozentenliste/v:dozent[@xml:id]

return
<dozentenliste xmlns="http://histvv.uni-leipzig.de/ns/2007" xml:lang="de">
  <universität>Leipzig</universität>
  {
    for $d in ( $alt | $neu )
    let $name := $d/v:name
    order by $name/v:nachname, not($name/v:vorname), $name/v:vorname
    return $d
  }
</dozentenliste>
