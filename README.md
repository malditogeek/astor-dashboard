Astor, an alternative to StatsD+Graphite
========================================

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

This can be useful if you want to run astor-dashboard locally but consume data from a remote astor-collector.

Deployment
----------

Once you have a successful deployment of [astor-collector](https://github.com/malditogeek/astor-collector), login into the machine again and do:

        sudo add-apt-repository ppa:chris-lea/node.js
        sudo apt-get update
        sudo apt-get install haproxy nodejs npm

  * Add port 80 to your [Security Group](http://i.imgur.com/fKi2M.png)

Then, on your local clone:

  * Copy _config/deploy.rb.sample_ to _config/deploy.rb_ and customize it with your repository
  * Copy _config/ec2.yml.sample_ to _config/ec2.yml_ and complete it with [your EC2 keys](http://i.imgur.com/UM9sa.png)

        cap deploy:setup
        cap deploy


TODO
----

  * Tree view for the metrics list
  * Configurable LIVE window (currently 60 datapoints)
  * Archive buttons (currently showing just -1 day)
  * Better alert handling
