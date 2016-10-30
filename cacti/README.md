# Datacenter supervision

We have a running cacti, graphing pdu, ups and temp.

We will send it to a influxdb on the supervision server, using cereustransporter cacti's pulgin.

We want [columned graphite data](http://roobert.github.io/2015/10/10/Columned-Graphite-Data-in-InfluxDB/) to have something like:
- pdu or ups:
-- phase1
-- phase2
-- phase3

ressources:
[influxdb github](https://github.com/influxdata/influxdb/blob/master/services/graphite/README.md)

## this is a part to do on your cacti server !!

add the plugins [cereustransporter](https://www.urban-software.com/products/nmid-plugins/cereustransporter/)

direct download the 0.64-1 version at https://www.urban-software.com/?ddownload=2433

put it in your plugins folder, unzip it

in plugins management, install and enable it

to to setting, and misc, then .... the field with the correct value

ex:
db: influxdb
port: 8083

to update
