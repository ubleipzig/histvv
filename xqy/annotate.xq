(:~
 : annotate.xq
 :
 : Copyright (C) 2018 Leipzig University Library <info@ub.uni-leipzig.de>
 :
 : Author: Carsten Milling <cmil@hashtable.de>
 :
 : This file is part of histvv.
 :
 : Histvv is free software: you can redistribute it and/or modify
 : it under the terms of the GNU General Public License as published by
 : the Free Software Foundation, either version 3 of the License, or
 : (at your option) any later version.
 :
 : Histvv is distributed in the hope that it will be useful,
 : but WITHOUT ANY WARRANTY; without even the implied warranty of
 : MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 : GNU General Public License for more details.
 :
 : You should have received a copy of the GNU General Public License
 : along with this program.  If not, see <http://www.gnu.org/licenses/>.
 :
 :
 : annotate.xq adds the following attributes to `vv` documents in the
 : database:
 :  - `x-semester` to the `vv` elements
 :  - `x-text`, `x-thema`, `x-dozenten`, `x-dozentenrefs` to `veranstaltung`
 :    elements
 :)

declare default element namespace 'http://histvv.uni-leipzig.de/ns/2007';

declare variable $uri external;

(:~
 : Construct semester ID
 :
 : @param $elem `vv` element
 :)
declare function local:semid ($vv as element(vv))
as xs:string {
  let $jahr := $vv/kopf/beginn/jahr/text()
  let $sem := if($vv/kopf/semester = 'Winter') then 'w' else 's'
  return $jahr || $sem
};

(:~
 : Remove elements with given names and expand `scil` and `anmerkung` elements
 :
 : @param $element element
 : @param $names names of elements to remove
 :)
declare function local:filter ($elem as element(), $names as xs:string*)
as element() {
  element { node-name($elem) } {
    $elem/@*,
    for $child in $elem/node()
    return
      if (name($child) = $names) then ''
      else if (name($child) = 'scil') then '[' || data($child/@text) || ']'
      else if (name($child) = 'anmerkung') then ' [' || $child/text() || ']'
      else if ($child instance of element()) then local:filter($child, $names)
      else $child
    }
};

(:~
 : Remove `seite` and expand `scil` and `anmerkung` descendents of $elem and
 : return its normalized text content.
 :
 : @param $elem element
 :)
declare function local:strip-text ($elem as element())
as xs:string {
  local:strip-text($elem, ())
};

(:~
 : Remove `seite` and elements with $names from $element, expand its `scil` and
 : `anmerkung` descendents and return its normalized text content.
 :
 : @param $elem element
 : @param $names names of elemens to remove
 :)
declare function local:strip-text ($elem as element(), $names as xs:string*)
as xs:string {
  normalize-space( local:filter($elem, ('seite', $names)) )
};

(:~
 : Find the respective `dozent` for a `ders` element
 :
 : @param $elem element
 :)
declare function local:resolve-ders ($elem as element())
as element() {
  if (name($elem) = 'ders' and not($elem/@ref))
  then $elem/preceding::dozent[1]
  else $elem
};

let $doc := doc($uri)

return (
  (: delete exisiting attributes :)
  delete node $doc/vv/@x-semester,
  delete node $doc//veranstaltung/@x-text,
  delete node $doc//veranstaltung/@x-thema,
  delete node $doc//veranstaltung/@x-dozenten,
  delete node $doc//veranstaltung/@x-dozentenrefs,

  (: insert x-semester :)
  insert node attribute x-semester {local:semid($doc/vv)} into $doc/vv,

  (: insert x-text, x-thema, x-dozenten, and x-dozentenrefs into :)
  for $v in $doc//veranstaltung

  (: gather relevant `thema` elements :)
  let $themen := $v/(ancestor::veranstaltungsgruppe/thema | thema)

  (: use title of `sachgruppe` if there is no `thema` or the `thema` is
   : connected via the `kontext` attribute
   :
   : TODO: follow sachgruppe/titel/@kontext
   :)
  let $sg := if (count($themen) = 0 or $v/thema[@kontext])
             then $v/ancestor::sachgruppe[1]/titel
             else ()

  let $dozenten := (
    if ($v/(dozent|ders))
    then $v/(dozent|ders)
    else $v/(
      ancestor::veranstaltungsgruppe/dozent[last()] |
      ancestor::veranstaltungsgruppe[ders][1]/ders)
    ) ! local:resolve-ders(.)

  let $x-thema := string-join(
    ($sg, $themen) ! local:strip-text(., 'anmerkung'),
    ' … '
  )

  let $x-dozenten := string-join(
    ($dozenten
      ! (if (name(.)='ders') then () else .)
      ! local:strip-text(.)
    ), '; '
  )

  let $x-dozentenrefs := string-join($dozenten/@ref, ' ')

  let $x-text := string-join(
    (
      $v,
      $themen except $v/thema,
      $sg,
      $dozenten except $v/dozent
    ) ! local:strip-text(.),
    ' | '
  )

  return (
    insert node attribute x-text {$x-text} into $v,
    insert node attribute x-thema {$x-thema} into $v,
    insert node attribute x-dozenten {$x-dozenten} into $v,
    insert node attribute x-dozentenrefs {$x-dozentenrefs} into $v
  )
)
