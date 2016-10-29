#!/bin/bash

### check existing installation
if [[ -d /etc/collectd/collectd.conf.d ]]; then
# do nothing
echo " "
 else 
# installing collectd
apt-get install collectd
fi

# getting right graphite IP
echo "Please type your graphite server IP"
echo "something like 192.168.2.99"
echo "======================="
read -p "type here" IP

# editing graphite.conf
sed -e "s/myserverIP/$IP/g" conf/graphite.conf

# copying files
cp conf/amqp.conf /etc/collectd/collectd.conf.d/amqp.conf
cp conf/graphite.conf /etc/collectd/collectd.conf.d/graphite.conf
cp conf/001-custom.yml /etc/xivo-ctid-ng/conf.d/001-custom.yml
#cp conf/network.conf /etc/collectd/collectd.conf.d/network.conf

# getting the queue to monitor
echo "Please type switboard or queue exten"
echo "something like 1234"
echo "======================="
read -p "type here" EXTEN

# editing switchboard_stats.conf
sed -e "s/1234/$EXTEN/g" switchboard_stats.conf
#or (if switchboard_stats.con is empty or more than one queue, may need loop)
#cat example.conf | sed -e "s/1234/$EXTEN/g" >> switchboard_stats.conf

# push dialplan with cp ??
# cp dialplan/switchboard_stats.conf /etc/xivo/asterisk/switchboard_stats.conf

#run logstash docker
docker run -p 25826:25826/udp -it --rm -v $(pwd):/config-dir logstash logstash -f /config-dir/logstash.conf
