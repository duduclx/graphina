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


