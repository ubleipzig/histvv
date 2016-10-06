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

app.get('/dozenten/', routeHandlerFactory('dozenten.xq', 'dozenten.xsl'));
app.get('/dozenten/galerie.html', routeHandlerFactory('dozenten.xq', 'dozenten.xsl'));
app.get('/dozenten/namen.html', routeHandlerFactory('dozentennamen.xq', 'dozenten.xsl'));
app.get('/dozenten/lookup/:name', routeHandlerFactory('dozentenlookup.xq', 'dozenten.xsl'));
app.get('/dozenten/:id.html', routeHandlerFactory('dozent.xq', 'dozenten.xsl'));
app.get('/suche/', routeHandlerFactory('suchformular.xq', 'suche.xsl'));
app.get('/suchergebnisse/', routeHandlerFactory('suche.xq', 'suche.xsl', [
  'start', 'interval', 'text', 'dozent', 'von', 'bis', 'fakultaet'
]));
app.get('/vv/', routeHandlerFactory('index.xq', 'vv.xsl'));
app.get('/vv/:id.html', routeHandlerFactory('semester.xq', 'vv.xsl'));

app.use(staticHtml(path.join(__dirname, 'public')));
app.use(finish(config.customXslFile));

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
  res.json({
    message: err.message,
    error: {}
  });
});


module.exports = app;
