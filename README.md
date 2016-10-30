# graphina
to use with debian 64bits (amd64) and tested on debian 8 jessie amd64

### !! This project is not ready to use at this time !! #

# task list:
1. supervisor server:
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

# details:
1. lastest graphite with:
 * carbon
 * whisper
 * collectd
 * influxdb
 * mysql
2. grafana 3.1.1 with:
 * custom dashboard for datacenter (pdu, ups, pue and temp)
 * custom dashbord for xivo (queue supervision, total calls, server stats)
 
## xivo ##
dedicated [xivo readme](https://github.com/duduclx/graphina/blob/master/xivo/README.md)
 ### swithboard ###
 - [x] configure collectd
 - [x] edit conf within the script
 - [ ] test dialplan on a IVR
 - [ ] create custom dashboard
 - [ ] validate the tool
 ### calls ###
 - [x] use carbon on the supervisor server
 - [x] edit conf within the script
 - [ ] create custom dashboard
 ### server ###
 - [ ] retrieve xivo's rra
 - [ ] create custom dashboard
 
 ## cacti ##
 dedicated [cacti readme](https://github.com/duduclx/graphina/blob/master/cacti/README.md)
 ### influxdb ###
 - [ ] configure influxdb
 - [ ] import template
 - [ ] custom dashbord
 
# How to use:

to proceed to installation, type in your terminal:
```
git clone https://github.com/duduclx/graphina.git
cd graphina
chmod a+x basic-install.sh
./basic-install.sh
```

# to remove the installer, run:
```
cd ~
rm -R graphina
```
