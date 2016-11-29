# saphir
to use with debian 64bits (amd64) and tested on debian 8 jessie amd64

this project is about have a supervisor server with:
- graphite using mysql database
- grafana dashboard
see details for more informations.

# task list:
## supervisor server:
- [x] have a working graphite
- [x] have a working carbon
- [x] have custom config for carbon
- [x] have a working collectd
- [x] have a working influxdb
- [x] have a working logstash
- [x] have some logstash plugins for elasticsearch
- [x] have a working elasticsearch
- [x] have a working phpmyadmin
- [x] have a working mysql
- [x] have a working grafana
- [x] add plugins to grafana
- [ ] add custom dashbord template for grafana
- [ ] add examples/script to feed data

# details:
1. lastest graphite with:
 * carbon
 * whisper
 * mysql (database for graphite)
 * phpmyadmin (to look at graphite's mysql)
2. grafana 3.1.1 with:
 * plugins (pie chart, diagram and histogram)
3. collector / database:
 * carbon & graphite
 * influxdb
 * collectd
 * logstash & elasticsearch
4. collect, graph, enjoy !!

# How to use:
You must be a super user to run it !
open terminal and type:
```
su
git clone https://github.com/duduclx/saphir.git
cd saphir
chmod a+x install_supervisor.sh
./install_supervisor.sh
```

# What's next:

Well, let's read the [start help](https://github.com/duduclx/saphir/blob/master/whatsnext.txt)

# list of services:

| service                 | :port                 | user          | password         | config directory          |
| ----------------------- | --------------------- | ------------- | ---------------- | ------------------------- |
| graphite                | :80                   | root          |  your_password   | /opt/graphite             |
| Carbon                  | :2003 :2004 :7002     |               |                  | /opt/graphite/conf        |
| whisper                 | none / carbon:2003    |               |                  | /opt/graphite/conf        |
| mysql                   | :3306                 | root          |  your_password   |                           |
| grafana                 | :3000                 | admin         |  admin           | /etc/grafana              |
| phpmyadmin              | 127.0.0.1/phpmyadmin  | root          |  your_password   | /opt/graphite             |
| influxdb interface      | :8083                 | admin         |  admin           | /etc/influxdb             |
| influxdb transport      | :8086                 |               |                  | /etc/influxdb             |
| elasticsearch interface | none / :9200          | elasticsearch | elasticsearch    | /usr/share/elasticsearch/ |
| elasticsearch transport | :9300                 |               |                  | /usr/share/elasticsearch/ |
| logstash                | :5044                 |               |                  | /opt/logstash             |
| collectd                | :25827                |               |                  | /etc/collectd             |
