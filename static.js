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

const path = require('path');
const fs = require('fs');
const parseurl = require('parseurl');
const libxslt = require('libxslt');

const xsldir = path.join(__dirname, 'xsl');

let xsl = fs.readFileSync(path.join(xsldir, 'static.xsl'), 'utf-8');
// fix include path's to satisfy node-libxslt
// see https://github.com/albanm/node-libxslt#includes
xsl = xsl.replace(/xsl:import href="/g, 'xsl:import href="' + xsldir + '/');

const stylesheet = libxslt.parse(xsl);

module.exports = function (dir) {
  return function (req, res, next) {
    if (res.headersSent || res.locals.body) {
      return next();
    }

    let file;
    let html;
    let filePath = parseurl(req).pathname;
    const m = filePath.match(/^(\/\w+)*\/(\w+\.html)?$/);
    if (m) {
      filePath = m[2] ? filePath : filePath + 'index.html';
      file = path.join(dir, filePath);
      try {
        html = fs.readFileSync(file, 'utf-8');
      } catch (error) {
        // log error if the file exists but cannot be read
        if (error.code !== 'ENOENT') {
          console.log(error);
        }
        return next();
      }
    } else {
      return next();
    }

    // stylesheet params
    const xslparams = {
      'histvv-url': req.originalUrl
    };

    html = stylesheet.apply(html, xslparams);
    res.set('Content-type', 'text/html');
    res.locals.body = html;
    next();
  };
};
