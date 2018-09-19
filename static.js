/*
 * static.js
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

var path = require('path');
var fs = require('fs');
var parseurl = require('parseurl');
var libxslt = require('libxslt');

var xsldir = 'xsl';

var xsl = fs.readFileSync(path.join(__dirname, xsldir, 'static.xsl'), 'utf-8');
// fix include path's to satisfy node-libxslt
// see https://github.com/albanm/node-libxslt#includes
xsl = xsl.replace(
  /xsl:import href="/g,
  'xsl:import href="' + xsldir + '/'
);

var stylesheet = libxslt.parse(xsl);

module.exports = function (dir) {

  return function (req, res, next) {
    if (res.headersSent || res.locals.body) {
      return next();
    }

    var file, html;
    var filePath = parseurl(req).pathname;
    var m = filePath.match(/^(\/\w+)*\/(\w+\.html)?$/);
    if (m) {
      filePath = m[2] ? filePath : filePath + 'index.html';
      file = path.join(dir, filePath);
      try {
        html = fs.readFileSync(file, 'utf-8');
      } catch (e) {
        // log error if the file exists but cannot be read
        if (e.code !== 'ENOENT') console.log(e);
        return next();
      }
    } else {
      return next();
    }

    // stylesheet params
    var xslparams = {
      'histvv-url': req.originalUrl
    };

    html = stylesheet.apply(html, xslparams);
    res.set('Content-type', 'text/html');
    res.locals.body = html;
    next();
  };

};
