/*
 * routehandler.js
 *
 * Copyright (C) 2018-2020 Leipzig University Library <info@ub.uni-leipzig.de>
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
const debug = require('debug')('histvv:routehandler');
const query = require('./query');

const xqydir = path.join(__dirname, 'xqy');
const xsldir = path.join(__dirname, 'xsl');

function loadFile (filename, dir) {
  const file = path.resolve(dir, filename);
  return fs.readFileSync(file, 'utf-8');
}

module.exports = function () {
  return function (xqyFile, xslFile, options) {
    options = options || {};
    debug({xqyFile, xslFile, options});

    const xqy = loadFile(xqyFile, xqydir);
    let xsl = loadFile(xslFile, xsldir);
    // fix include path's to satisfy node-libxslt
    // see https://github.com/albanm/node-libxslt#includes
    xsl = xsl.replace(
      /xsl:import href="/g,
      'xsl:import href="' + xsldir + '/'
    );

    const stylesheet = libxslt.parse(xsl);

    async function routeHandler (request, response, next) {
      debug({params: request.params});
      // add route params to query vars
      const vars = {};
      Object.keys(request.params).forEach(name => {
        vars[name] = request.params[name];
      });

      if (options.queryParams) {
        debug(request.query);
        options.queryParams.forEach(k => {
          if (request.query[k]) {
            const value = Array.isArray(request.query[k])
              ? request.query[k].join(' ') : request.query[k];
            vars[k] = value;
          }
        });
      }

      // stylesheet params
      const xslparams = options.xslParams ? options.xslParams(request) : {};
      xslparams['histvv-url'] = request.originalUrl;

      debug({xqy, vars});
      const dbResponse = await query(xqy, vars);

      const xml = dbResponse.data;
      // debug({xml});

      if (xml === '') {
        next();
        return;
      }

      let body;
      let {send, type = 'html'} = options;
      let status = 200;

      try {
        body = stylesheet.apply(xml, xslparams);
      } catch (error) {
        // console.log(dbResponse.data);
        console.log(error);
        let line = '';
        if (error.line) {
          line = xml.split('\n')[error.line - 1];
          console.log({line});
        }

        send = true;
        status = 500;
        type = 'text/plain';
        body = `Internal server error\n\n${error.message}\n`;
        Object.keys(error).forEach(key => {
          body += `${key}: ${error[key]}\n`;
        });
      } finally {
        response.type(type);
        if (send) {
          response.status(status).send(body);
        } else {
          response.locals.body = body;
          next();
        }
      }
    }

    return routeHandler;
  };
};
