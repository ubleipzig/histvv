# Histvv Server

The histvv server is an [Express](http://expressjs.com) based web application
serving data and documentation for the [HistVV
Project](http://histvv.uni-leipzig.de).

## Synopsis

```bash
npm install -g github:ubleipzig/histvv
histvv-server
```

## Prerequisites

### BaseX

The histvv server uses the REST API of a [BaseX](http://basex.org) XML database
to access and query a collection of XML files conforming to the [Histvv
Schema](https://github.com/ubleipzig/histvv-schema). BaseX is expected to be run
in [client/server mode](https://docs.basex.org/wiki/Database_Server):

```bash
basexhttp -S
```

The histvv server has been tested with __BaseX version 9.4.2__.

### Node.js

As an Express application, the histvv server requires
[Node.js](https://nodejs.org/) to run. It has been tested with
__Node version 12.18.0__.

## Options

The `histvv-server` command  accepts the following command line options:

* `--port` the port the histvv server listens on (default: `3000`)
* `--db` the name of basex database to use (default: `histvv`)
* `--dbhost` the basex server host (default: `localhost`)
* `--dbport` the basex server port (default: `8984`)
* `--user` username of the basex user (default: `admin`)
* `--password` password of the basex user (default: `admin`)
* `--static` a directory of files to be served by the histvv server in addition
  to database resources (default: none, see
  https://github.com/ubleipzig/histvv-data/blob/master/public as an example)
* `--xsl` a custom XSL stylesheet to post-process the HTML produced by the
  histvv server (default: none, see
  https://github.com/ubleipzig/histvv-data/blob/master/custom.xsl as an example)

## Example

To serve the [data of the Histvv project at Leipzig
University](https://github.com/ubleipzig/histvv-data) run the following
commands:

```bash
# clone the data repository
git clone https://github.com/ubleipzig/histvv-data.git
# start the database server
basexserver -S
# create and populate the database
# (make sure to use the -w option to preserve white space in the documents)
basex -w -c 'create db histvv ./histvv-data/xml'
# install the histvv server globally
npm install -g github:ubleipzig/histvv
# start the server passing in static data and a custom stylesheet
histvv-server --static ./histvv-data/public --xsl ./histvv-data/custom.xsl
```

Now the server can be accessed under http://localhost:3000/. It can be stopped
with the `Ctrl-C` key combination.

## Docker

The `Dockerfile` in this repo allows to build and run a docker container like this:

```bash
docker build  -t histvv/server .
docker run -ti -p 3000:3000 -e dbhost=10.1.2.3 histvv/server
```

This would run a containerized histvv-server connecting to a BaseX database
hosted at `10.1.2.3` (with the default port `8984` and database name `histvv`).
It would be available at http://localhost:3000/.

The exposed port of the histvv-server and the database it connects to can be
overridden from the command line:

```bash
docker run -ti \
  -p 3003:3000 \
  -e dbhost=10.1.2.3 \
  -e dbport=8999 \
  -e dbname=histvv_leipzig \
  histvv/server
```

## Development

With `npm start` you can run an instance of the histvv server that reloads
whenever you change the code:

```bash
git clone https://github.com/ubleipzig/histvv.git
cd histvv
npm start
```

You can pass options to the dev server like this:

```bash
npm start -- --port 3003 --db histvv_dev
```

To enable debug output run

```bash
DEBUG=histvv:* npm start
```


## Author

Carsten Milling <cmil@hashtable.de>

## License

Copyright (C) 2018-2020 Leipzig University Library <info@ub.uni-leipzig.de>

Histvv is free software: you can redistribute it and/or modify it under the
terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

Histvv is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program.  If not, see <http://www.gnu.org/licenses/>.
