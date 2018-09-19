/*
 * finish.js
 *
 * Copyright (C) 2018 Leipzig University Library <info@ub.uni-leipzig.de>
 *
 * Author: Carsten Milling <cmil@hashtable.de>
 *
 * This file is part of histvv.
 *
 * Histvv is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Histvv is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

'use strict';

const fs = require('fs');
const libxslt = require('libxslt');

module.exports = function (xslfile) {
  let stylesheet;
  if (xslfile) {
    const xsl = fs.readFileSync(xslfile, 'utf-8');
    stylesheet = libxslt.parse(xsl);
  }

  return function (req, res, next) {
    if (!res.locals.body) {
      return next();
    }

    let {body} = res.locals;
    if (stylesheet && /^text\/html/.test(res.get('Content-type'))) {
      body = stylesheet.apply(body, {'histvv-url': req.originalUrl});
    }
    res.send(body);
  };
};
