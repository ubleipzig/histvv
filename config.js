'use strict';

var nconf = require('nconf');
var resolve = require('path').resolve;

function cwdResolve (filepath) {
  return filepath ? resolve(process.cwd(), filepath) : null;
}

nconf.argv().env();
nconf.defaults({
  dbname: 'histvv'
});

var config = {
  dbname: nconf.get('dbname'),
  dataDir: cwdResolve(nconf.get('data_dir')),
  customXslFile: cwdResolve(nconf.get('custom_xsl'))
};

module.exports = config;
