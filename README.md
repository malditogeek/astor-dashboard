Astor, an alternative to StatsD/Graphite
========================================

API compatible with StatsD. Replacement for Graphite.

![Astor Dashboard](http://i.imgur.com/xtTtS.png)

This is: astor-dashboard
---------------
Real-time metric visualization. Based on SocketStream (Node) and Backbone.

You'll also need: astor-collector
---------------
Metric collector and REST API. Based on EventMachine, Goliath and LevelDB. [Find it here.](https://github.com/malditogeek/astor-collector)

Pre-requisites
--------------

  * Node.js
  * ZeroMQ dev 

Getting started
---------------

If you already have a working Node environment, should be as easy as:

    npm install
    node app.js

The dashboard consumes data from localhost by default. If you're going to consume data from a different host, you'll need to update:

  * app.js
  * client/code/app/entry.coffee

Deployment
----------

TBD

TODO
----

  * Tree view for the metrics list
  * Configurable LIVE window (currently 60 datapoints)
  * Archive buttons (currently showing just -1 day)
  * Better alert handling
