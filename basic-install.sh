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
apt-get install python-dev libcairo2-dev libffi-dev python-pip fontconfig apache2 libapache2-mod-wsgi git

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
PYTHONPATH=$GRAPHITE_HOME/webapp django-admin.py migrate --settings=graphite.settings --run-syncdb

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

### need minimalist local_settings
### you may need to edit it for email and more stuff
cp local_settings.py $GRAPHITE_SETTING/local_settings.py

### running graphite
a2dissite 000-default
a2ensite graphite
a2enmod ssl
a2enmod socache_shmcb
a2enmod rewrite
service apache2 reload

### installing grafana
wget https://grafanarel.s3.amazonaws.com/builds/grafana_3.1.1-1470047149_amd64.deb
apt-get install -y adduser libfontconfig
dpkg -i grafana_3.1.1-1470047149_amd64.deb

### start grafana and make it running at boot
service grafana-server start
update-rc.d grafana-server defaults

### restart apache
/bin/systemctl reload
/bin/systemctl enable grafana-server
/bin/systemctl start grafana-server
service apache2 reload
service apache2 restart

### removing install tools
#rm -R graphina
#rm grafana_3.1.1-1470047149_amd64.deb

### more info
#clear
#echo "
#graphite web interface is located at \n
#http://127.0.0.1 \n
#\n
#grafana web interface is located at \n
#http://127.0.0.1:3000 \n
#"



