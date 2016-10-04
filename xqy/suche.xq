declare namespace v = "http://histvv.uni-leipzig.de/ns/2007";

declare variable $start external := 1;
declare variable $interval external := 50;
declare variable $von external := '';
declare variable $bis external := '';
declare variable $text external := '';
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
    ($text = '' or contains(@x-text, $text))
    and
    ($dozent = '' or contains(@x-dozenten, $dozent))
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
    return
    <stelle id="{$v/@xml:id}" semester="{$sem}" jahr="{$jahr}">
      <thema>{string($v/@x-thema)}</thema>
      <dozenten>{$dozenten}</dozenten>
      <text>{normalize-space($v)}</text>
    </stelle>
  }
  </stellen>
  <suche>
    <text>{$text}</text>
    <dozent>{$dozent}</dozent>
    <von>{$von}</von>
    <bis>{$bis}</bis>
    <fakultaet>{$fakultaet}</fakultaet>
  </suche>
</report>
