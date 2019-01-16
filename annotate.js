/*
 * annotate.js
 *
 * Copyright (C) 2019 Leipzig University Library <info@ub.uni-leipzig.de>
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
const path = require('path');
const async = require('async');

const xqFindDocs =
  'declare namespace v = "http://histvv.uni-leipzig.de/ns/2007";' +
  '/v:vv[not(@x-semester)]/base-uri()';

const queryfile = path.join(__dirname, 'xqy', 'annotate.xq');
const xqAnnotate = fs.readFileSync(queryfile, 'utf-8');

module.exports = function (dbSession) {
  return new Promise((resolve, reject) => {
    const queryFind = dbSession.query(xqFindDocs);
    const queryAnnotate = dbSession.query(xqAnnotate);

    queryFind.execute((err, r) => {
      if (err) {
        return reject(err);
      }
      const uris = r.result ? r.result.split('\n') : [];
      if (uris.length > 0) {
        console.log('Annotating documents...');
      }
      async.each(uris, (uri, cb) => {
        queryAnnotate.bind('uri', uri, '');
        queryAnnotate.execute(err => {
          if (err) {
            return cb(err);
          }
          console.log(`${uri}`);
          cb();
        });
      }, err => {
        if (err) {
          return reject(err);
        }
        resolve(uris.length);
      });
    });
  });
};
