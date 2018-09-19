(:~
 : elementlookup.xq
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

declare variable $element-name := "modus";
declare variable $element-content := "publice";

let $stellen := /v:vv[v:kopf/v:status/@komplett]
  //*[name(.)=$element-name and normalize-space(.)=$element-content]

let $n := count($stellen)

return
<report>
  <element>{$element-name}</element>
  <value>{$element-content}</value>
  <n>{$n}</n>
  <stellen>
  {
    for $d in $stellen
    let $node := $d/..
    let $s := if ($n < 100)
      then $node/preceding::v:seite[1]
      else ()
    let $snr := if ($s)
                then (if ($s/@nr) then $s/@nr else $s/string())
                else '0'
    let $kopf := $d/ancestor::v:vv/v:kopf
    let $sem := $kopf/v:semester/string()
    let $jahr := $kopf/v:beginn/v:jahr/string()
    return
    <stelle semester="{$sem}" jahr="{$jahr}" seite="{$snr}">
    {$node}
    </stelle>
  }
  </stellen>
</report>
