#!/bin/bash

# getting right graphite IP
echo "Please type your graphite server IP"
echo "something like 192.168.2.99"
echo "======================="
read -p IP

# editing graphite.conf
sed 's/myserverIP/$IP/' graphite.conf

# copying files
cp amqp.conf /etc/collectd/collectd.conf.d
cp graphite.conf /etc/collectd/collectd.conf.d

# don't forget to
# push dialplan with cp ??
echo "do not forget to create the dialplan !"
echo "with the correct exten value, yeah"
