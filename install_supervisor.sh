#!/bin/bash

### configuring path
GRAPHITE_HOME='/opt/graphite'
GRAPHITE_CONF="${GRAPHITE_HOME}/conf"
GRAPHITE_STORAGE="${GRAPHITE_HOME}/storage"
GRAPHITE_SETTING="${GRAPHITE_HOME}/webapp/graphite"
#GRAPHITE_ROOT="${GRAPHITE_HOME}"

### check existing installation
if [[ -d $GRAPHITE_HOME ]]; then
  echo "Looks like you already have a Graphite installation in ${GRAPHITE_HOME}, aborting."
  exit 1
fi

### update and install needed packages
apt-get update -y
apt-get install -y python-dev libcairo2-dev libffi-dev fontconfig apache2 libapache2-mod-wsgi
apt-get install -y python-cairo python-django python-pip python-pyparsing python-memcache
#apt-get install python-django-tagging
apt-get install -y uwsgi uwsgi-plugin-python

pip install pytz
pip install 'django-tagging<0.4'

### installing from pip
pip install whisper
pip install carbon
pip install graphite-web
#pip install https://github.com/graphite-project/ceres/tarball/master

### set up a new database and create the initial schema
#PYTHONPATH=$GRAPHITE_HOME/webapp django-admin.py migrate --settings=graphite.settings --run-syncdb

# cleaning terminal
clear

### configuring graphite
cp $GRAPHITE_CONF/graphite.wsgi.example $GRAPHITE_CONF/graphite.wsgi
cp $GRAPHITE_CONF/carbon.conf.example $GRAPHITE_CONF/carbon.conf
cp $GRAPHITE_CONF/dashboard.conf.example $GRAPHITE_CONF/dashboard.conf
cp $GRAPHITE_CONF/graphTemplates.conf.example $GRAPHITE_CONF/graphTemplates.conf

### moving examples
mkdir $GRAPHITE_CONF/examples
mv $GRAPHITE_CONF/*.example $GRAPHITE_CONF/examples/

### moving dir
cd conf
### installing configured carbon conf files
cp carbon/storage-schemas.conf $GRAPHITE_CONF/storage-schemas.conf
cp carbon/storage-aggregation.conf $GRAPHITE_CONF/storage-aggregation.conf
### need minimalist local_settings
### you may need to edit it for email and more stuff
cp graphite/local_settings.py $GRAPHITE_SETTING/local_settings.py
# editing mysecret for local_settings.py
#cd ${GRAPHITE_HOME}/webapp/graphite
# edit $GRAPHITE_SETTING/local_settings.py with generated secretkey
# python manage.py generate_secret_key [--replace] [secretkey.txt]
# SECRET=$( cat secretkey.txt )
#sed -e "s/mysecretkey/$SECRET/g" $GRAPHITE_SETTING/local_settings.py
### installing apache conf file
cp apache2/graphite.conf /etc/apache2/sites-available/graphite.conf

### creating database
# installing mysql
apt-get -y install mysql-server

clear

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
clear

### instructions for phpmyadmin
echo "Select apache2 with the spacebar."
echo "When asked to configure database for phpmyadmin with dbconfig-common,"
echo "select yes."
pause 10
apt-get install phpmyadmin

### set pythonpath for django to run
export PYTHONPATH=/usr/local/lib/python2.7/site-packages

# Setup the Django database
cd ${GRAPHITE_HOME}/webapp/graphite
python manage.py syncdb --noinput
chown www-data:www-data ${GRAPHITE_STORAGE}/graphite.db
chown -R www-data:www-data /opt/graphite/{storage,webapp}

PYTHONPATH=$GRAPHITE_ROOT/webapp django-admin.py migrate --settings=graphite.settings --run-syncdb
#/usr/lib/python2.7/site-packages/graphite/manage.py syncdb

### installing grafana
wget https://grafanarel.s3.amazonaws.com/builds/grafana_3.1.1-1470047149_amd64.deb
apt-get install -y adduser libfontconfig
dpkg -i grafana_3.1.1-1470047149_amd64.deb

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
influx << EOF
CREATE DATABASE cacti
USE cacti
DROP DATABASE _internal
EOF

### installing elasticsearch
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.0.0.deb
dpkg -i elasticsearch-5.0.0.deb
### see https://www.elastic.co/guide/en/elasticsearch/reference/master/settings.html for config file

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
update-rc.d influxdb defaults

### start elasticsearch and make it running at boot
service elasticsearch start
update-rc.d elasticsearch defaults
sudo /etc/init.d/elasticsearch start

### run graphite
cd ${GRAPHITE_HOME}/bin
./carbon-cache.py start
#and
cd ${GRAPHITE_HOME}/webapp/graphite
chmod +x manage.py
./manage.py runserver
