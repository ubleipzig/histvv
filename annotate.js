/*
 * annotate.js
 *
 * Copyright (C) 2019-2020 Leipzig University Library <info@ub.uni-leipzig.de>
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
const query = require('./query');

const xqFindDocs =
  'declare namespace v = "http://histvv.uni-leipzig.de/ns/2007";' +
  '/v:vv[not(@semester)]/base-uri()';

const queryfile = path.join(__dirname, 'xqy', 'annotate.xq');
const xqAnnotate = fs.readFileSync(queryfile, 'utf-8');

module.exports = async function () {
  return new Promise((resolve, reject) => {
    // eslint-disable-next-line promise/prefer-await-to-then
    query(xqFindDocs).then(response => {
      const {data} = response;
      const uris = data ? data.split('\n') : [];
      if (uris.length > 0) {
        console.log('Annotating documents...');
      }

      uris.forEach(async uri => {
        try {
          await query(xqAnnotate, {uri});
          console.log(`${uri}`);
        } catch (error) {
          console.log(error);
          return reject(error);
        }
      });

      resolve(uris.length);
    }).catch(error => {
      console.log(error);
      return reject(error);
    });
  });
};
