# saphir
to use with debian 64bits (amd64) and tested on debian 8 jessie amd64

### !! This project is not ready to use at this time !! ###

this project is about have a supervisor server for:
- retrieve metrics from a cacti server to the influxdb
in my case, the cacti is used to graph pdu, ups, and temp from a datacenter room
- retreive metrics from a xivo server to differents database
retrieve calls and dahdi metrics for global calls stats to the carbon service
server metrics for global usage of the server and the postgresql

# task list:
## supervisor server:
- [ ] have a working graphite
- [ ] have a working carbon
- [x] have custom config for carbon
- [x] have a working collectd
- [ ] have custom config for collectd
- [x] have a working influxdb
- [ ] have custom config file for influxdb
- [x] have a working phpmyadmin
- [x] have a working mysql
- [x] have a working grafana
- [x] add plugins to grafana
- [ ] add custom dashbord template for grafana
- [ ] add examples/script to feed data

## xivo ##
This is a compilation of short python scripts that interact with an asterik telephony server using the AMI over a telnet connection.

The data it collects from there is then sent to the local Carbon service.

requirements:
- You need Asterisk 1.8+ or xivo 13.07+.
- Add AMI users in asterisks.
- The DADHI user needs read-permissions for "call" and the general one needs write-permissions for "command".
- For more information about this please consult the Asterisk documentation.

this part is provided by [niklasR/zweig](https://github.com/niklasR/zweig)

Enter the details for the servers, including host, port, username (asterisk only) and secret (asterisk only).
### calls ###
- [x] use carbon on the supervisor server
- [x] edit conf within the script
- [ ] create custom dashboard
### server ###
- [ ] retrieve xivo's rra
- [ ] create custom dashboard

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
3. xivo calls
 * retrieve **call metrics** in **Carbon** from the xivo's collectd.
 * "calls" are internal calls
 * "dahdi" are channels (calls passing by the dahdi module)
4. xivo server stats
We retrieve the data generating by the default "monitoring" service from xivo
and intend to retreive it under grafana and so have **server stats**


# How to use:
## supervisor server
to install the tools, type in your terminal:
```
git clone https://github.com/duduclx/saphir.git
cd saphir/install
chmod a+x install_supervisor.sh
./install_supervisor.sh
```
## xivo
to install the calls metric supervision, type in your terminal:
```
cd saphir/install
chmod +x install_calls.sh
./install_calls.sh
```

# list of services:
| service                 | :port                 | user          | password         | config directory    |
| ----------------------- | --------------------- | ------------- | ---------------- | ------------------- |
| graphite                | :8080                 |               |                  | /opt/graphite       |
| Carbon                  | :2003 :2004 :7002     |               |                  | /opt/graphite/conf  |
| whisper                 | none /carbon:2003     |               |                  | /opt/graphite/conf  |
| mysql                   | :3306                 | root          |  <your_password> |                     |
| grafana                 | :3000                 | admin         |  admin           | /etc/grafana        |
| phpmyadmin              | 127.0.0.1/phpmyadmin  | root          |  <your_password> | /opt/graphite       |
| influxdb interface      | :8086                 | admin         |  admin           | /etc/influxdb       |
| influxdb transport      | :8083                 |               |                  | /etc/influxdb       |
| elasticsearch interface | :9200                 | elasticsearch | elasticsearch    | /etc/elasticsearch/ |
| elasticsearch transport | :9300                 |               |                  | /etc/elasticsearch/ |
| logstash                | :5044                 |               |                  | /opt/logstash       |





