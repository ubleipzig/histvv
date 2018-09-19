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

The histvv server uses a [BaseX](http://basex.org) XML database to access and
query a collection of XML files conforming to the [Histvv
Schema](https://github.com/ubleipzig/histvv-schema). BaseX is expected to be run
in [client/server mode](http://docs.basex.org/wiki/Startup#Client.2FServer):

```bash
basexserver -S
```

To initially load the XML files from the [Histvv data
repository](https://github.com/ubleipzig/histvv-data) follow these steps:

```bash
git clone https://github.com/ubleipzig/histvv-data.git
basex -c 'create db histvv ./histvv-data/xml'
# NB: the next command can take serveral minutes
basex -i histvv https://raw.githubusercontent.com/ubleipzig/histvv/master/xqy/annotate.xq
```

## Options

The `histvv-server` command  accepts the following command line options:

* `--port` the port the histvv server listens on (default: `3000`)
* `--db` the name of basex database to use (default: `histvv`)
* `--dbhost` the basex server host (default: `localhost`)
* `--dbport` the basex server port (default: `1984`)
* `--user` username of the basex user (default: `admin`)
* `--password` password of the basex user (default: `admin`)
* `--static` a directory of files to be served by the histvv server in addition
  to database resources (default: none, see
  https://github.com/ubleipzig/histvv-data/blob/master/public as an example)
* `--xsl` a custom XSL stylesheet to post-process the HTML produced by the
  histvv server (default: none, see
  https://github.com/ubleipzig/histvv-data/blob/master/custom.xsl as an example)

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

## Author

Carsten Milling <cmil@hashtable.de>

## License

Copyright (C) 2018 Leipzig University Library <info@ub.uni-leipzig.de>

Histvv is free software: you can redistribute it and/or modify it under the
terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

Histvv is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program.  If not, see <http://www.gnu.org/licenses/>.
