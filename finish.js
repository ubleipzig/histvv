'use strict';

var fs = require('fs');
var libxslt = require('libxslt');

module.exports = function (xslfile) {

  var stylesheet;
  if (xslfile) {
    var xsl = fs.readFileSync(xslfile, 'utf-8');
    stylesheet = libxslt.parse(xsl);
  }

  return function (req, res, next) {
    if (!res.locals.body) {
      return next();
    }

    var body = res.locals.body;
    if (stylesheet && /^text\/html/.test(res.get('Content-type'))) {
      body = stylesheet.apply(body, {'histvv-url': req.originalUrl});
    }
    res.send(body);
  };

};
