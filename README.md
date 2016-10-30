# graphina
to use with debian 64bits (amd64) and tested on debian 8 jessie amd64

### !! This project is not ready to use at this time !! #

# task list:
## supervisor server:
- [ ] have a working graphite
- [ ] have a working carbon
- [ ] have custom config for carbon
- [x] have a working collectd
- [ ] have custom config for collectd
- [x] have a working influxdb
- [ ] have custom config file for influxdb
- [x] have a working grafana
- [x] add plugins to grafana
- [ ] add custom dashbord template for grafana
- [ ] add examples/script to feed data
## xivo ##
dedicated [xivo readme](https://github.com/duduclx/graphina/blob/master/xivo/README.md)
 - [x] switchboard
 - [x] calls
 - [ ] server
 ## cacti ##
 dedicated [cacti readme](https://github.com/duduclx/graphina/blob/master/cacti/README.md)
 - [ ] supervisor server

# details:
1. lastest graphite with:
 * carbon
 * whisper
 * influxdb
 * mysql
2. grafana 3.1.1 with:
 * custom dashboard for datacenter (pdu, ups, pue and temp)
 * custom dashbord for xivo (queue supervision, total calls, server stats)
3. xivo 16.02+ with:
 * collectd
 * stashlog docker
 * postgresql to collectd
 
# How to use:
## supervisor server
to install the tools, type in your terminal:
```
git clone https://github.com/duduclx/graphina.git
cd graphina
chmod a+x basic-install.sh
./basic-install.sh
```
## xivo
to install the calls metric supervision, type in your terminal:
```
cd graphina/xivo/calls
chmod +x install_cacmec.sh
./install_cacmec.sh
```
to install the switchboard, connect to your xivo server first, then type in your terminal:
```
git clone https://github.com/duduclx/graphina.git
cd graphina/xivo/switchboard
install_xivo_switchboard_stats.sh
```

# to remove the installer, run:
```
cd ~
rm -R graphina
```
