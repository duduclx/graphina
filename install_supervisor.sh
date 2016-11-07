#!/bin/bash

### configuring path
GRAPHITE_HOME='/opt/graphite'
GRAPHITE_CONF="${GRAPHITE_HOME}/conf"
GRAPHITE_STORAGE="${GRAPHITE_HOME}/storage"
GRAPHITE_SETTING="${GRAPHITE_HOME}/webapp/graphite"
GRAPHITE_EXAMPLES="${GRAPHITE_HOME}/examples"

### check existing installation
if [[ -d $GRAPHITE_HOME ]]; then
  echo "Looks like you already have a Graphite installation in ${GRAPHITE_HOME}, aborting."
  exit 1
fi

### update and install needed packages
apt-get update -y
apt-get install -y python-dev libcairo2-dev libffi-dev fontconfig apache2 libapache2-mod-wsgi
apt-get install -y python-cairo python-django python-pip python-pyparsing python-memcache python-mysqldb
#apt-get install python-django-tagging
apt-get install -y uwsgi uwsgi-plugin-python
apt-get install -y openjdk-8-jre wget

wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://packages.elastic.co/logstash/2.4/debian stable main" | tee -a /etc/apt/sources.list
apt-get update -y
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
#cp $GRAPHITE_EXAMPLES/local_settings.py.example $GRAPHITE_SETTING/local_settings.py
### using mine (mysql)
cp conf/graphite/local_settings.py $GRAPHITE_SETTING/local_settings.py
# editing mysecret for local_settings.py
#cd ${GRAPHITE_HOME}/webapp/graphite
# edit $GRAPHITE_SETTING/local_settings.py with generated secretkey
# python manage.py generate_secret_key [--replace] [secretkey.txt]
# SECRET=$( cat secretkey.txt )
#sed -e "s/mysecretkey/$SECRET/g" $GRAPHITE_SETTING/local_settings.py
### installing apache conf file
cp conf/apache2/graphite.conf /etc/apache2/sites-available/graphite.conf

# installing logstash conf
cp conf/logstash/logstash.conf /etc/logstash/logstash.conf

### moving dir
mkdir temp
cd temp

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
#influx << EOF
#CREATE DATABASE cacti
#USE cacti
#DROP DATABASE _internal
#EOF

### installing elasticsearch
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.0.0.deb
dpkg -i elasticsearch-5.0.0.deb
### see https://www.elastic.co/guide/en/elasticsearch/reference/master/settings.html for config file

### cleaning temp
cd ..
rm -R temp

### creating database
# installing mysql
apt-get -y install mysql-server

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
echo "Select apache2 with the spacebar."
echo "When asked to configure database for phpmyadmin with dbconfig-common,"
echo "select yes."

sleep 10
apt-get -y install phpmyadmin

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
service elasticsearch start
update-rc.d elasticsearch defaults
/etc/init.d/elasticsearch start

### run graphite
cd ${GRAPHITE_HOME}/bin
./carbon-cache.py start
#and
cd ${GRAPHITE_HOME}/webapp/graphite
chmod +x manage.py
#./manage.py runserver
python manage.py syncdb

# end of script
echo " "
echo " "
echo "_______________"
echo "end of script"
echo "cheers !"
echo "_______________"
