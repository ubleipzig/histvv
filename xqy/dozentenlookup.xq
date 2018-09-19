(:~
 : dozentenlookup.xq
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
 :)

declare namespace v = "http://histvv.uni-leipzig.de/ns/2007";

declare variable $name external := "Drobisch";

let $stellen := /v:vv[v:kopf/v:status/@komplett]
  //v:dozent[not(@ref) and normalize-space(v:nachname)=$name]

return
<report>
  <name>{$name}</name>
  <stellen >
  {
    for $d in $stellen
    let $node := $d/..
    let $s := $node/preceding::v:seite[1]
    let $snr := if ($s)
                then (if ($s/@nr) then $s/@nr else $s/string())
                else '1'
    let $kopf := $d/ancestor::v:vv/v:kopf
    let $sem := $kopf/v:semester/string()
    let $jahr := $kopf/v:beginn/v:jahr/string()
    return
    <stelle semester="{$sem}" jahr="{$jahr}" seite="{$snr}">
    {normalize-space($node)}
    </stelle>
  }
  </stellen>
</report>
