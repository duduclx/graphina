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

git clone https://github.com/graphite-project/graphite-web.git
git clone https://github.com/graphite-project/carbon.git
git clone https://github.com/graphite-project/whisper.git

cd graphite-web
python setup.py install
cd ../carbon
python setup.py install
cd ../whisper
python setup.py install
cd ..

### installing vhost conf for apache

cp graphite.conf /etc/apache2/sites-available/graphite.conf
a2ensite graphite
service apache2 reload

### set up a new database and create the initial schema
PYTHONPATH=$GRAPHITE_HOME/webapp django-admin.py migrate --settings=graphite.settings --run-syncdb

### configuring graphite

cp $GRAPHITE_CONF/graphite.wsgi.example $GRAPHITE_CONF/graphite.wsgi
cp $GRAPHITE_CONF/carbon.conf.example $GRAPHITE_CONF/carbon.conf
cp $GRAPHITE_CONF/storage-schemas.conf.example $GRAPHITE_CONF/storage-schemas.conf

echo "[stats]\npattern = ^stats.*\nretentions = 10:2160,60:10080,600:262974" >> $GRAPHITE_CONF/storage-schemas.conf

cp storage-aggregation.conf $GRAPHITE_CONF/storage-aggregation.conf

### moving examples
mkdir $GRAPHITE_CONF/examples
mv $GRAPHITE_CONF/*.example $GRAPHITE_CONF/examples/

### need minimalist local_settings
#cp $GRAPHITE_SETTING/local_settings.py.example $GRAPHITE_SETTING/local_settings.py

### installing grafana

wget https://grafanarel.s3.amazonaws.com/builds/grafana_3.1.1-1470047149_amd64.deb
apt-get install -y adduser libfontconfig
dpkg -i grafana_3.1.1-1470047149_amd64.deb

### start grafana and make it running at boot
service grafana-server start
update-rc.d grafana-server defaults
