# saphir
to use with debian 64bits (amd64) and tested on debian 8 jessie amd64

### !! This project is not ready to use at this time !! ###

this project is about have a supervisor server with:
- graphite using mysql database
- grafana dashboard
see details for more informations.

# task list:
## supervisor server:
- [x] have a working graphite
- [x] have a working carbon
- [x] have custom config for carbon
- [ ] have a working collectd
- [ ] have custom config for collectd
- [x] have a working influxdb
- [ ] have custom config file for influxdb
- [ ] have a working elasticsearch
- [ ] have custom config file for elasticsearch
- [x] have a working phpmyadmin
- [x] have a working mysql
- [x] have a working grafana
- [x] add plugins to grafana
- [ ] add custom dashbord template for grafana
- [ ] add examples/script to feed data

# details:
1. lastest graphite with:
 * carbon (used for xivo)
 * whisper
 * influxdb (database for cacti)
 * mysql (database for graphite)
 * phpmyadmin (to look at graphite's mysql)
2. grafana 3.1.1 with:
 * plugins (pie chart, diagram and histogram)
 * custom dashboard for datacenter (pdu, ups, pue and temp)
 * custom dashbord for xivo (queue supervision, total calls, server stats)
3. xivo calls & server stats
 * retrieve **call metrics** in **Carbon** from the xivo's collectd.
 * monitor the xivo's server from his postgresql to the collectd in the supervisor server.

# How to use:
open terminal and type:
```
git clone https://github.com/duduclx/graphina.git
chmod a+x install_supervisor.sh
./install_supervisor.sh
```

# What's next:

Well, let's read the [start help](https://github.com/duduclx/graphina/blob/master/whatsnext.txt)

# list of services:

| service                 | :port                 | user          | password         | config directory    |
| ----------------------- | --------------------- | ------------- | ---------------- | ------------------- |
| graphite                | :80                   | root          |  your_password   | /opt/graphite       |
| Carbon                  | :2003 :2004 :7002     |               |                  | /opt/graphite/conf  |
| whisper                 | none /carbon:2003     |               |                  | /opt/graphite/conf  |
| mysql                   | :3306                 | root          |  your_password   |                     |
| grafana                 | :3000                 | admin         |  admin           | /etc/grafana        |
| phpmyadmin              | 127.0.0.1/phpmyadmin  | root          |  your_password   | /opt/graphite       |
| influxdb interface      | :8086                 | admin         |  admin           | /etc/influxdb       |
| influxdb transport      | :8083                 |               |                  | /etc/influxdb       |
| elasticsearch interface | :9200                 | elasticsearch | elasticsearch    | /etc/elasticsearch/ |
| elasticsearch transport | :9300                 |               |                  | /etc/elasticsearch/ |
| logstash                | :5044                 |               |                  | /opt/logstash       |
| collectd                | :xxxx                 |               |                  | /etc/collectd       |

