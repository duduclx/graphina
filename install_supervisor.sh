#!/bin/bash

### configuring path
GRAPHITE_HOME='/opt/graphite'
GRAPHITE_CONF="${GRAPHITE_HOME}/conf"
GRAPHITE_STORAGE="${GRAPHITE_HOME}/storage"
GRAPHITE_SETTING="${GRAPHITE_HOME}/webapp/graphite"
GRAPHITE_EXAMPLES="${GRAPHITE_HOME}/examples"

### getting default dir
echo "$PWD" >> pwd.txt
DIR="$( cat pwd.txt)"

### check existing installation
if [[ -d $GRAPHITE_HOME ]]; then
  echo "Looks like you already have a Graphite installation in ${GRAPHITE_HOME}, aborting."
  exit 1
fi

### adding backports to sources
echo "deb http://http.debian.net/debian jessie-backports main" | tee -a /etc/apt/sources.list
apt-get update

### update and install needed packages
apt-get install -y apt-transport-https zip curl wget
apt-get install -y python-dev libcairo2-dev libffi-dev fontconfig apache2 libapache2-mod-wsgi
apt-get install -y python-cairo python-django python-pip python-pyparsing python-memcache python-mysqldb
#apt-get install python-django-tagging
apt-get install -y uwsgi uwsgi-plugin-python
apt-get install -y openjdk-8-jre-headless openjdk-8-jre

wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | apt-key add -
echo "deb https://packages.elastic.co/logstash/2.4/debian stable main" | tee -a /etc/apt/sources.list
apt-get update
apt-get install logstash

pip install pytz
pip install 'django-tagging<0.4'

### installing from pip
pip install whisper
pip install carbon
pip install graphite-web
#pip install https://github.com/graphite-project/ceres/tarball/master

# cleaning terminal
#clear

### configuring graphite
cp $GRAPHITE_CONF/graphite.wsgi.example $GRAPHITE_CONF/graphite.wsgi
cp $GRAPHITE_CONF/carbon.conf.example $GRAPHITE_CONF/carbon.conf
cp $GRAPHITE_CONF/dashboard.conf.example $GRAPHITE_CONF/dashboard.conf
cp $GRAPHITE_CONF/graphTemplates.conf.example $GRAPHITE_CONF/graphTemplates.conf

### moving examples
mv $GRAPHITE_CONF/*.example $GRAPHITE_EXAMPLES

### installing configured carbon conf files
cp conf/carbon/storage-schemas.conf $GRAPHITE_CONF/storage-schemas.conf
cp conf/carbon/storage-aggregation.conf $GRAPHITE_CONF/storage-aggregation.conf

### need minimalist local_settings
### you may need to edit it for email and more stuff

### using default (examples)
cp $GRAPHITE_EXAMPLES/local_settings.py.example $GRAPHITE_SETTING/local_settings.py

### installing apache conf file
cp conf/apache2/graphite.conf /etc/apache2/sites-available/graphite.conf

# installing collectd
apt-get install collectd
# need update conf
mv /etc/collectd/collectd.conf /etc/collectd/collectd.conf.default
cp conf/collectd/collectd.conf /etc/collectd/collectd.conf
cp conf/collectd/network.conf /etc/collectd/collectd.conf.d/network.conf

# installing logstash conf
cp conf/logstash/logstash.conf /etc/logstash/logstash.conf
# installing logstash plugins
#/opt/logstash/bin/logstash-plugin install logstash-input-LDAPSearch
/opt/logstash/bin/logstash-plugin install logstash-filter-translate
/opt/logstash/bin/logstash-plugin install logstash-filter-cidr
/opt/logstash/bin/logstash-plugin install logstash-filter-elasticsearch

### moving dir
mkdir temp
cd temp

### installing grafana
wget https://grafanarel.s3.amazonaws.com/builds/grafana_latest_amd64.deb
apt-get install -y adduser libfontconfig
dpkg -i grafana_4.0.0-1480439068_amd64.deb

### installing grafana plugins
# pie chart
grafana-cli plugins install grafana-piechart-panel
# diagram
grafana-cli plugins install jdbranham-diagram-panel
# histogram
grafana-cli plugins install mtanda-histogram-panel

### installing influxdb
wget https://dl.influxdata.com/influxdb/releases/influxdb_1.0.2_amd64.deb
dpkg -i influxdb_1.0.2_amd64.deb
### see https://docs.influxdata.com/influxdb/v0.9/introduction/installation/ for config file
# create influxdb database
#influx << EOF
#CREATE DATABASE cacti
#USE cacti
#DROP DATABASE _internal
#EOF

### installing elasticsearch
#wget -qO - https://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add -
#echo "deb http://packages.elasticsearch.org/elasticsearch/1.5/debian stable main" > /etc/apt/sources.list.d/elasticsearch.list
# from apt
#sudo apt-get update && sudo apt-get install elasticsearch
# from deb
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.0.1.deb
dpkg -i elasticsearch-5.0.1.deb

### cleaning temp
cd ..
rm -R temp

### creating correct path
mkdir -p /usr/share/elasticsearch/config/scripts

### installing conf files
cp conf/elasticsearch/elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml
cp /etc/elasticsearch/logging.yml /usr/share/elasticsearch/config/logging.yml
cp /etc/elasticsearch/elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml.default

### setting permissions
chmod g+rwx /usr/share/elasticsearch/config/elasticsearch.yml /usr/share/elasticsearch/config/logging.yml 
chmod o+rwx /usr/share/elasticsearch/config/elasticsearch.yml /usr/share/elasticsearch/config/logging.yml

### start elasticsearch and make it running at boot
/bin/systemctl daemon-reload
/bin/systemctl enable elasticsearch.service
systemctl start elasticsearch.service

### checking elasticsearch
## curl -XGET http://localhost:9200

### creating database
# installing mysql
apt-get install mysql-server

# cleaning terminal
#clear

# ask for user and password for editing local-settings.py
echo "Please type your mysql password for root user"
echo "something like Mys3cr3t"
echo "======================="
read -p " type here " MYSQL

# create user and database for graphite
mysql -u root -p$MYSQL << EOF
create database graphite;
create user 'graphite'@'localhost' identified by 'graphite_password';
grant all on graphite.* to 'graphite';
EOF

### installing phpmyadmin
apt-get -y install mcrypt
service apache2 restart

# cleaning terminal
#clear

### instructions for phpmyadmin
#echo "Select apache2 with the spacebar."
#echo "When asked to configure database for phpmyadmin with dbconfig-common,"
#echo "select yes."

#sleep 10
apt-get install phpmyadmin

### set pythonpath for django to run
export PYTHONPATH=/usr/local/lib/python2.7/site-packages

# Setup the Django database
cd ${GRAPHITE_HOME}/webapp/graphite
python manage.py syncdb --noinput
chown www-data:www-data ${GRAPHITE_STORAGE}/graphite.db
chown -R www-data:www-data /opt/graphite/{storage,webapp}

### set up a new database and create the initial schema
#PYTHONPATH=$GRAPHITE_HOME/webapp django-admin.py migrate --settings=graphite.settings --run-syncdb
#/usr/lib/python2.7/site-packages/graphite/manage.py syncdb

### running services
a2dissite 000-default
a2ensite graphite
a2enmod ssl
a2enmod socache_shmcb
a2enmod rewrite
/bin/systemctl reload
/bin/systemctl enable grafana-server
/bin/systemctl start grafana-server
service apache2 reload
service apache2 restart

### start grafana and make it running at boot
service grafana-server start
update-rc.d grafana-server defaults

### start influxdb and make it running at boot
service influxdb start

### start elasticsearch and make it running at boot
/bin/systemctl daemon-reload
/bin/systemctl enable elasticsearch.service
systemctl start elasticsearch.service

### run graphite
cd ${GRAPHITE_HOME}/bin
./carbon-cache.py start
#and
cd ${GRAPHITE_HOME}/webapp/graphite
chmod +x manage.py
#./manage.py runserver
python manage.py syncdb

### using mysql
cd $DIR
cp conf/graphite/local_settings.py $GRAPHITE_SETTING/local_settings.py
#migrate db
python manage.py syncdb

# end of script
echo " "
echo " "
echo "_______________"
echo "end of script"
echo "cheers !"
echo "_______________"
