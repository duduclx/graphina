#!/bin/bash

# getting right graphite IP
echo "Please type your graphite server IP"
echo "something like 192.168.2.99"
echo "======================="
read -p IP

# editing graphite.conf
sed 's/myserverIP/$IP/' graphite.conf

# copying files
cp conf/amqp.conf /etc/collectd/collectd.conf.d
cp conf/graphite.conf /etc/collectd/collectd.conf.d

# push dialplan with cp ??
# cp dialplan/xivo_stats.conf /etc/xivo/asterisk/xivo_stats.conf

# don't forget to
echo "do not forget to create the dialplan !"
echo "with the correct exten value, yeah"
