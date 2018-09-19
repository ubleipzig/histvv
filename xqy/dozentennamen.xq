(:~
 : dozentennamen.xq
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
