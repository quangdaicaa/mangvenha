#!/usr/bin/bash

# --------------------
NAME=217.76.56.249

cd ~
CONFIG=~/configGeo/configMaster
GIT=https://github.com/quangdaicaa/configGeo.git
apt update
apt install -y git
git clone $GIT

CONFIG=~/configGeo/configMaster
DEBIAN_FRONTEND=noninteractive
WORKON_HOME=~/.virtualenvs
USER=root
TOMCAT_VERSION=9.0.70

GIT=https://github.com/quangdaicaa/configGeo.git
GEONODE_GIT=https://github.com/GeoNode/geonode.git
POSTGRES_KEY=https://www.postgresql.org/media/keys/ACCC4CF8.asc
TOMCAT_FILE=https://www-eu.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz

apt install -y \
  software-properties-common build-essential \
  python3-all-dev python3.10-dev python3.10-venv virtualenvwrapper \
  libxml2 libxml2-dev gettext libmemcached-dev zlib1g-dev \
  libxslt1-dev libjpeg-dev libpng-dev libpq-dev \
  unzip gcc libgeos-dev libproj-dev lsb-release \
  sqlite3 spatialite-bin libsqlite3-mod-spatialite libsqlite3-dev \
  openjdk-11-jdk-headless default-jdk-headless \
  neovim wget curl iproute2 \
  nginx uwsgi uwsgi-plugin-python3 python3-certbot-nginx \
  erlang rabbitmq-server memcached
add-apt-repository -y ppa:ubuntugis/ppa
echo "deb http://apt.postgresql.org/pub/repos/apt/ jammy-pgdg main" >> /etc/apt/sources.list.d/pgdg.list
wget --no-check-certificate --quiet -O - $POSTGRES_KEY | apt-key add -
apt update
apt install -y --allow-downgrades \
  python3-gdal=3.4.1+dfsg-1build4 \
  gdal-bin=3.4.1+dfsg-1build4 \
  libgdal-dev=3.4.1+dfsg-1build4 \
  libgdal30=3.4.1+dfsg-1build4 \
  postgresql-13 postgresql-13-postgis-3 \
  postgresql-13-postgis-3-scripts postgresql-13 postgresql-client-13
gdalinfo --version
python3.10 --version
which python3.10
java -version

source /usr/share/virtualenvwrapper/virtualenvwrapper.sh
mkvirtualenv --python=/usr/bin/python3.10 geonode
workon geonode
echo "export WORKON_HOME=~/.virtualenvs" >> ~/.bashrc
echo "source /usr/share/virtualenvwrapper/virtualenvwrapper.sh" >> ~/.bashrc
mkdir -p /opt/geonode
usermod -a -G www-data $USER
chown -Rf $USER:www-data /opt/geonode
chmod -Rf 775 /opt/geonode
cd /opt
git clone $GEONODE_GIT -b 4.x geonode
cd /opt/geonode
pip install -r requirements.txt --upgrade
pip install -e . --upgrade
pip install pygdal=="`gdal-config --version`.*" pylibmc==1.6.3 sherlock==0.3.2

service postgresql start
sudo -Hiu postgres psql -c "CREATE USER geonode WITH PASSWORD 'geonode';"
sudo -Hiu postgres createdb -O geonode geonode
sudo -Hiu postgres createdb -O geonode geonode_data
sudo -Hiu postgres psql -d geonode -c 'CREATE EXTENSION postgis;'
sudo -Hiu postgres psql -d geonode -c 'GRANT ALL ON geometry_columns TO PUBLIC;'
sudo -Hiu postgres psql -d geonode -c 'GRANT ALL ON spatial_ref_sys TO PUBLIC;'
sudo -Hiu postgres psql -d geonode -c 'GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO geonode;'
sudo -Hiu postgres psql -d geonode -c 'GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO geonode;'
sudo -Hiu postgres psql -d geonode_data -c 'CREATE EXTENSION postgis;'
sudo -Hiu postgres psql -d geonode_data -c 'GRANT ALL ON geometry_columns TO PUBLIC;'
sudo -Hiu postgres psql -d geonode_data -c 'GRANT ALL ON spatial_ref_sys TO PUBLIC;'
sudo -Hiu postgres psql -d geonode_data -c 'GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO geonode;'
sudo -Hiu postgres psql -d geonode_data -c 'GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO geonode;'
nvim /etc/postgresql/13/main/pg_hba.conf
service postgresql restart
# psql -U postgres geonode
# psql -U geonode geonode
# psql -U postgres geonode_data
# psql -U geonode geonode_data

useradd -m -U -d /opt/tomcat -s /bin/bash tomcat
usermod -a -G www-data tomcat
wget $TOMCAT_FILE
mkdir -p /opt/tomcat
tar -xf apache-tomcat-${TOMCAT_VERSION}.tar.gz -C /opt/tomcat
rm apache-tomcat-${TOMCAT_VERSION}.tar.gz
ln -s /opt/tomcat/apache-tomcat-${TOMCAT_VERSION} /opt/tomcat/latest
chown -R tomcat:www-data /opt/tomcat
JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")
echo $JAVA_HOME
ln -s /usr/lib/jvm/java-1.11.0-openjdk-amd64/jre /usr/lib/jvm/jre
nvim /etc/systemd/system/tomcat9.service
###
systemctl daemon-reload
systemctl enable tomcat9.service
systemctl start tomcat9.service
systemctl status tomcat9.service
ss -ltn
ufw allow 8080/tcp

# source ~/.virtualenvs/geonode/bin/activate
# service postgresql restart
# systemctl restart tomcat9.service