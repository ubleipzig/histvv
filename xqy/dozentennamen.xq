declare default element namespace "http://histvv.uni-leipzig.de/ns/2007";

let $namen := /vv[kopf/status/@komplett]
                         //dozent[not(@ref)]
                          /nachname[not(seite)]/normalize-space()

let $neu := for $n in distinct-values($namen)
            return
            <dozent xmlns="http://histvv.uni-leipzig.de/ns/2007">
              <name><nachname>{$n}</nachname></name>
            </dozent>

let $alt := /dozentenliste/dozent[@xml:id]

return
<dozentenliste xmlns="http://histvv.uni-leipzig.de/ns/2007" xml:lang="de">
  {
    for $d in ( $alt | $neu )
    let $name := $d/name
    order by $name/nachname, not($name/vorname), $name/vorname
    return $d
  }
</dozentenliste>
