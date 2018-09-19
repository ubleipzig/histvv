(:~
 : suche.xq
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

declare variable $start external := 1;
declare variable $interval external := 50;
declare variable $von external := '';
declare variable $bis external := '';
declare variable $volltext external := '';
declare variable $dozent external := '';
declare variable $fakultaet external := '';

let $start := if (number($start) > 0) then number($start) else 1
let $interval := if (number($interval) >= 10 and number($interval) <= 200)
  then number($interval) else 50

let $sems := /v:vv/@x-semester/data()
let $semcount := count($sems)
let $min-sem := $sems[1]
let $max-sem := $sems[$semcount]

let $von := if(
    matches($von, '^[0-9]{4}[ws]$') and $von >= $min-sem and $von <= $max-sem
  ) then $von else $min-sem
let $bis := if(
    matches($bis, '^[0-9]{4}[ws]$') and $bis >= $min-sem and $bis <= $max-sem
  ) then $bis else $max-sem

let $stellen := /v:vv[@x-semester >= $von and @x-semester <= $bis]
  //v:sachgruppe[
    @fakultät and (@fakultät = tokenize($fakultaet) or $fakultaet = '')
  ]
  //v:veranstaltung[
    ($volltext = ''
      or @x-text contains text {tokenize($volltext)} all using stemming
         using language "German")
    and
    ($dozent = '' or @x-dozenten contains text {tokenize($dozent)})
  ]

let $total := count($stellen)

return
<report>
  <stellen total="{$total}" start="{$start}" interval="{$interval}">
  {
    for $v in subsequence($stellen, $start, $interval)
    let $dozenten := if ($v/v:dozent)
                   then $v/v:dozent
                   else (if ($v/v:ders)
                         then $v/v:ders/preceding::v:dozent[1]
                         else $v/ancestor::v:veranstaltungsgruppe/v:dozent[last()])
    let $kopf := $v/ancestor::v:vv/v:kopf
    let $sem := $kopf/v:semester/string()
    let $jahr := $kopf/v:beginn/v:jahr/string()
    order by $kopf/v:beginn/v:jahr, $kopf/v:ende/v:jahr
    return
    <stelle id="{$v/@xml:id}" semester="{$sem}" jahr="{$jahr}">
      <thema>{string($v/@x-thema)}</thema>
      <dozenten>{$dozenten}</dozenten>
      <text>{normalize-space($v)}</text>
    </stelle>
  }
  </stellen>
  <suche>
    <text>{$volltext}</text>
    <dozent>{$dozent}</dozent>
    <von>{$von}</von>
    <bis>{$bis}</bis>
    <fakultaet>{$fakultaet}</fakultaet>
  </suche>
</report>
