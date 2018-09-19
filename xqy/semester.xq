(:~
 : semester.xq
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

declare default element namespace 'http://histvv.uni-leipzig.de/ns/2007';

declare variable $id external;

let $semester := if (substring($id, 5) = "w") then "Winter" else "Sommer"
let $jahr := substring($id, 1, 4)

for $d in /vv
let $k := $d/kopf
where $k/status[@komplett = "ja"]
  and $k/semester = $semester
  and $k/beginn/jahr = $jahr
return $d
