(:~
 : dozent.xq
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

declare variable $id external := "anger_r";

let $daten := /v:dozentenliste/v:dozent[@xml:id=$id]
let $veranstaltungen := /v:vv[v:kopf/v:status/@komplett]
  //v:veranstaltung[tokenize(@x-dozentenrefs, "\s+") = $id]

return
if ($daten) then
<report>
  {$daten}
  <stellen>
  {
    for $v in $veranstaltungen return
    <stelle semester="{$v/ancestor::v:vv/@x-semester}">
    {$v}
    {
     if ($v/v:dozent[@ref = $id])
     then ""
     else (if ($v/v:ders)
           then $v/v:ders/preceding::v:dozent[1]
           else $v/ancestor::v:veranstaltungsgruppe/v:dozent[@ref = $id][last()])
    }
    </stelle>
  }
  </stellen>
  <n>{count($veranstaltungen)}</n>
</report>
else
()
