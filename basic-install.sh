### update and install needed packages

apt-get update -y
apt-get install python-dev libcairo2-dev libffi-dev python-pip fontconfig apache2 libapache2-mod-wsgi

### installing graphite-web carbon and whisper from pip

export PYTHONPATH="/opt/graphite/lib/:/opt/graphite/webapp/"
pip install https://github.com/graphite-project/whisper/tarball/master
pip install https://github.com/graphite-project/carbon/tarball/master
pip install https://github.com/graphite-project/graphite-web/tarball/master

### installing vhost conf for apache

cp graphite.conf /etc/apache2/sites-available/graphite.conf

### configuring path

GRAPHITE_HOME='/opt/graphite'
GRAPHITE_CONF="${GRAPHITE_HOME}/conf"
GRAPHITE_STORAGE="${GRAPHITE_HOME}/storage"

### set up a new database and create the initial schema
PYTHONPATH=$GRAPHITE_HOME/webapp django-admin.py migrate --settings=graphite.settings --run-syncdb

### configuring graphite

#cd $GRAPHITE_CONF
#cp graphite.wsgi.example graphite.wsgi
#cp carbon.conf.example carbon.conf
#cp storage-schemas.conf.example storage-schemas.conf

cp storage-aggregation.conf $GRAPHITE_CONF/storage-aggregation.conf
