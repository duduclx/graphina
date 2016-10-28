#!/bin/bash

### configuring path
GRAPHITE_HOME='/opt/graphite'
GRAPHITE_CONF="${GRAPHITE_HOME}/conf"
GRAPHITE_STORAGE="${GRAPHITE_HOME}/storage"
GRAPHITE_SETTING="${GRAPHITE_HOME}/webapp/graphite"

### check existing installation
if [[ -d $GRAPHITE_HOME ]]; then
  echo "Looks like you already have a Graphite installation in ${GRAPHITE_HOME}, aborting."
  exit 1
fi

### update and install needed packages
apt-get update -y
apt-get install python-dev libcairo2-dev libffi-dev python-pip fontconfig apache2 libapache2-mod-wsgi

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

pip install whisper
pip install carbon
pip install graphite-web

### installing vhost conf for apache
cp graphite.conf /etc/apache2/sites-available/graphite.conf

### set up a new database and create the initial schema
#PYTHONPATH=$GRAPHITE_HOME/webapp django-admin.py migrate --settings=graphite.settings --run-syncdb

### configuring graphite
cp $GRAPHITE_CONF/graphite.wsgi.example $GRAPHITE_CONF/graphite.wsgi
cp $GRAPHITE_CONF/carbon.conf.example $GRAPHITE_CONF/carbon.conf
cp $GRAPHITE_CONF/dashboard.conf.example $GRAPHITE_CONF/dashboard.conf
cp $GRAPHITE_CONF/graphTemplates.conf.example $GRAPHITE_CONF/graphTemplates.conf
cp $GRAPHITE_CONF/storage-schemas.conf.example $GRAPHITE_CONF/storage-schemas.conf

echo "[stats]\npattern = ^stats.*\nretentions = 10:2160,60:10080,600:262974" >> $GRAPHITE_CONF/storage-schemas.conf

cp storage-aggregation.conf $GRAPHITE_CONF/storage-aggregation.conf

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

### testing graphite-mysql
#wget https://storage.googleapis.com/golang/go1.7.3.linux-amd64.tar.gz
#tar -C /usr/local -xzf go1.7.3.linux-amd64.tar.gz
#export PATH=$PATH:/usr/local/go/bin
#export GOPATH=$HOME/go
#export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
#
#go get -u github.com/marpaia/graphite-golang
#go get -u github.com/op/go-logging
#go get -u github.com/go-sql-driver/mysql
#git clone https://github.com/akashihi/graphite-mysql.git
#cd graphite-mysql
#go build .
#
#graphite-mysql -host 127.0.0.1 -port 3306 -user root -password secret -metrics-host 192.168.1.1 -metrics-port 2003 -metrics-prefix test -period 60

### need minimalist local_settings
### you may need to edit it for email and more stuff
cp local_settings.py $GRAPHITE_SETTING/local_settings.py

# Setup the Django database
cd ${GRAPHITE_HOME}/webapp/graphite
python manage.py syncdb --noinput
chown www-data:www-data ${GRAPHITE_STORAGE}/graphite.db

### installing grafana
wget https://grafanarel.s3.amazonaws.com/builds/grafana_3.1.1-1470047149_amd64.deb
apt-get install -y adduser libfontconfig
dpkg -i grafana_3.1.1-1470047149_amd64.deb

### start grafana and make it running at boot
service grafana-server start
update-rc.d grafana-server defaults

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
