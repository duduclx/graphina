# graphina
to use with debian 64bits (amd64)

tested on debian 8 jessie amd64

no grafana package for I386.

# !! This project is not ready to use at this time !! #
Come back later

cheers

# task list:
- [ ] have a working graphite
- [ ] have a working collectd
- [x] have a working grafana
- [ ] have custom config file
- [ ] add examples/script to feed data
- [ ] add custom dashbord template

# details:
1. lastest graphite with:
 * carbon
 * whisper
 * collectd
 * mysql
2. grafana 3.1.1 with:
 * custom dashboard for datacenter (pdu, ups, pue and temp)
 * custom dashbord for xivo (queue supervision, total calls, server stats)

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
