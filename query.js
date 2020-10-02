/*
 * query.js
 *
 * Copyright (C) 2020 Leipzig University Library <info@ub.uni-leipzig.de>
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

const axios = require('axios');
const debug = require('debug')('histvv:query');

const {
  db: {
    name: dbname,
    port = 8984,
    host,
    user: username = 'admin',
    password = 'admin'
  }
} = require('./config');

const url = `http://${host}:${port}/rest/${dbname}`;

debug(`Connected to database at ${url}`);

module.exports = async function (xquery, vars = {}) {
  debug({xquery, vars});
  let variables = '';
  Object.keys(vars).forEach(key => {
    const name = key.replace(/"/g, '&quot');
    const value = vars[key].replace(/"/g, '&quot');
    variables += `<variable name="${name}" value="${value}"/>\n`;
  });

  const payload = `
<query>
${variables}
<text><![CDATA[${xquery}]]></text>
</query>`;
  debug({payload});

  try {
    const response = await axios({
      url,
      method: 'POST',
      data: payload,
      headers: {
        'Content-Type': 'application/xml'
      },
      auth: {username, password}
    });
    return response;
  } catch (error) {
    console.log(error);
  }
};
