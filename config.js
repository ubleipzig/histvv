/*
 * config.js
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

const {resolve} = require('path');
const nconf = require('nconf');

function cwdResolve (filepath) {
  return filepath ? resolve(process.cwd(), filepath) : null;
}

nconf.argv().env();
nconf.defaults({
  dbname: 'histvv'
});

const config = {
  dbname: nconf.get('dbname'),
  dataDir: cwdResolve(nconf.get('data_dir')),
  customXslFile: cwdResolve(nconf.get('custom_xsl'))
};

module.exports = config;
