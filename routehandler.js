/*
 * routehandler.js
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
const libxslt = require('libxslt');

const xqydir = path.join(__dirname, 'xqy');
const xsldir = path.join(__dirname, 'xsl');

function loadFile (filename, dir) {
  const file = path.resolve(dir, filename);
  return fs.readFileSync(file, 'utf-8');
}

module.exports = function (dbSession) {
  return function (xqyFile, xslFile, options) {
    options = options || {};

    const xqy = loadFile(xqyFile, xqydir);
    let xsl = loadFile(xslFile, xsldir);
    // fix include path's to satisfy node-libxslt
    // see https://github.com/albanm/node-libxslt#includes
    xsl = xsl.replace(
      /xsl:import href="/g,
      'xsl:import href="' + xsldir + '/'
    );

    const stylesheet = libxslt.parse(xsl);
    const query = dbSession.query(xqy);

    function routeHandler (request, response, next) {
      // bind route params to the query
      Object.keys(request.params).forEach(name => {
        query.bind(name, request.params[name], '');
      });

      if (options.queryParams) {
        options.queryParams.forEach(k => {
          if (request.query[k]) {
            const value = Array.isArray(request.query[k])
              ? request.query[k].join(' ') : request.query[k];
            query.bind(k, value, '', console.log);
          }
        });
      }

      // stylesheet params
      const xslparams = options.xslParams ? options.xslParams(request) : {};
      xslparams['histvv-url'] = request.originalUrl;

      query.execute((err, r) => {
        if (err) {
          console.log(err);
        }

        if (r.result === '') {
          next();
          return;
        }

        const body = stylesheet.apply(r.result, xslparams);
        response.type(options.type || 'html');
        if (options.send) {
          response.send(body);
        } else {
          response.locals.body = body;
          next();
        }
      });
    }

    return routeHandler;
  };
};
