### !! this script is to use on the xivo server !! ###

# XiVO switchoard statistics

To run this, you need to have a Xivo version 16.02 or above.

Also, you need to know:
- graphite server IP
- the Exten of the queue to monitor

# how to use

run
````
./install_xivo_switchboard_stats.sh
````

# how it works

In order to have Switchboard statistics, we need to generate events when calls are created, answered, hung up, etc.
The chosen implementation is to send events to collectd via RabbitMQ:
- It uses collectd to retrieve data, 
- store the events in the logs of the logstash container.
- and send it to carbon service on the graphite server.

more informations and ressources:
- [xivo feature \#6071](http://projects.xivo.io/issues/6071)
- [sboily xivo stats](https://github.com/sboily/xivo-stats)
- [sboily conf](https://github.com/sboily/config)
