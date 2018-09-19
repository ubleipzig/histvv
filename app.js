/*
 * app.js
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

var express = require('express');
var path = require('path');
var logger = require('morgan');
var basex = require('basex');
var staticHtml = require('./static');
var finish = require('./finish');
var config = require('./config');

var session = new basex.Session();
session.execute('OPEN ' + config.dbname, function (err, r) {
  if (err) {
    console.error(err);
  }
  console.log(r.info);
});

var routeHandlerFactory = require('./routehandler.js')(session);

var app = express();

app.set('strict routing', true);

app.use(logger('dev'));

// redirect search without query to search form
app.get('/suche/', function (req, res, next) {
  if (Object.keys(req.query).length === 0) {
    res.redirect(301, '/suche.html');
  } else {
    next();
  }
});

app.get('/dozenten/', routeHandlerFactory('dozenten.xq', 'dozenten.xsl'));
app.get('/dozenten/galerie.html', routeHandlerFactory('dozenten.xq', 'dozenten.xsl'));
app.get('/dozenten/namen.html', routeHandlerFactory('dozentennamen.xq', 'dozenten.xsl'));
app.get('/dozenten/lookup/:name', routeHandlerFactory('dozentenlookup.xq', 'dozenten.xsl'));
app.get('/dozenten/:id.html', routeHandlerFactory('dozent.xq', 'dozenten.xsl'));
app.get('/pnd.txt', routeHandlerFactory('dozenten.xq', 'beacon.xsl', {
  send: true, type: 'text', xslParams: function (req) {
    var base = req.protocol + '://' + req.get('host');
    return {
      'histvv-beacon-feed': base + req.originalUrl,
      'histvv-beacon-target': base + '/pnd/{ID}'
    };
  }
}));
app.get('/suche.html', routeHandlerFactory('suchformular.xq', 'suche.xsl'));
app.get('/suche/', routeHandlerFactory('suche.xq', 'suche.xsl', {
  queryParams: ['start', 'interval', 'volltext', 'dozent', 'von', 'bis',
                'fakultaet']
}));
app.get('/vv/', routeHandlerFactory('index.xq', 'vv.xsl'));
app.get('/vv/:id.html', routeHandlerFactory('semester.xq', 'vv.xsl'));

if (config.dataDir) {
  app.use(staticHtml(config.dataDir));
}
app.use(staticHtml(path.join(__dirname, 'public')));
app.use(finish(config.customXslFile));

if (config.dataDir) {
  app.use(express.static(config.dataDir));
}
app.use(express.static(path.join(__dirname, 'public')));


// catch 404 and forward to error handler
app.use(function(req, res, next) {
  var err = new Error('Not Found');
  err.status = 404;
  next(err);
});

// error handlers

// development error handler
// will print stacktrace
if (app.get('env') === 'development') {
  app.use(function(err, req, res, next) {
    res.status(err.status || 500);
    res.json({
      message: err.message,
      error: err
    });
  });
}

// production error handler
// no stacktraces leaked to user
app.use(function(err, req, res, next) {
  res.status(err.status || 500);
  res.type('text');
  res.send(err.message);
});


module.exports = app;
