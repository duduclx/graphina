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
apt-get install python-dev libcairo2-dev libffi-dev fontconfig apache2 libapache2-mod-wsgi
apt-get install python-cairo python-django python-pip python-pyparsing python-memcache
#apt-get install python-django-tagging
apt-get install uwsgi uwsgi-plugin-python

pip install pytz
pip install 'django-tagging<0.4'
### installing using github source
#git clone https://github.com/graphite-project/graphite-web.git
#git clone https://github.com/graphite-project/carbon.git
#git clone https://github.com/graphite-project/whisper.git

#cd graphite-web
#python setup.py install
#cd ../carbon
#python setup.py install
#cd ../whisper
#python setup.py install
#cd ..

### installing from pip
pip install whisper
pip install carbon
pip install graphite-web
#pip install https://github.com/graphite-project/ceres/tarball/master

### installing vhost conf for apache
cp apache2/graphite.conf /etc/apache2/sites-available/graphite.conf

### set up a new database and create the initial schema
#PYTHONPATH=$GRAPHITE_HOME/webapp django-admin.py migrate --settings=graphite.settings --run-syncdb

### configuring graphite
cp $GRAPHITE_CONF/graphite.wsgi.example $GRAPHITE_CONF/graphite.wsgi
cp $GRAPHITE_CONF/carbon.conf.example $GRAPHITE_CONF/carbon.conf
cp $GRAPHITE_CONF/dashboard.conf.example $GRAPHITE_CONF/dashboard.conf
cp $GRAPHITE_CONF/graphTemplates.conf.example $GRAPHITE_CONF/graphTemplates.conf

cp conf/storage-schemas.conf $GRAPHITE_CONF/storage-schemas.conf
cp conf/storage-aggregation.conf $GRAPHITE_CONF/storage-aggregation.conf

### moving examples
mkdir $GRAPHITE_CONF/examples
mv $GRAPHITE_CONF/*.example $GRAPHITE_CONF/examples/

### creating database
apt-get install mysql-server
# ask for user and password for editing local-settings.py
mysql -u root -p
#enter password then
create database graphite;
create user 'graphite'@'localhost' identified by 'graphite_password';
grant all on graphite.* to 'graphite';
exit
#default port 3306

### installing phpmyadmin
apt-get install mcrypt
service apache2 restart
apt-get install phpmyadmin
#Select “apache2.”
#When asked to configure database for phpmyadmin with dbconfig-common, select yes

### need minimalist local_settings
### you may need to edit it for email and more stuff
cp graphite/local_settings.py $GRAPHITE_SETTING/local_settings.py

### set pythonpath for django to run
export PYTHONPATH=/usr/local/lib/python2.7/site-packages

# Setup the Django database
cd ${GRAPHITE_HOME}/webapp/graphite
# edit $GRAPHITE_SETTING/local_settings.py with generated secretkey
# python manage.py generate_secret_key [--replace] [secretkey.txt]
# SECRET=$( cat secretkey.txt )
# sed 's/mysecretkey/$SECRET/' $GRAPHITE_SETTING/local_settings.py
python manage.py syncdb --noinput
chown www-data:www-data ${GRAPHITE_STORAGE}/graphite.db
chown -R www-data:www-data /opt/graphite/{storage,webapp}

PYTHONPATH=$GRAPHITE_ROOT/webapp django-admin.py migrate --settings=graphite.settings --run-syncdb
#/usr/lib/python2.7/site-packages/graphite/manage.py syncdb

### run graphite
#cd ${GRAPHITE_HOME}/webapp
#./manage.py runserver

### installing grafana
wget https://grafanarel.s3.amazonaws.com/builds/grafana_3.1.1-1470047149_amd64.deb
apt-get install -y adduser libfontconfig
dpkg -i grafana_3.1.1-1470047149_amd64.deb

### start grafana and make it running at boot
service grafana-server start
update-rc.d grafana-server defaults

### installing influxdb
wget https://dl.influxdata.com/influxdb/releases/influxdb_1.0.2_amd64.deb
dpkg -i influxdb_1.0.2_amd64.deb

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
