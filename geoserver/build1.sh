#!/usr/bin/bash

# --------------------
NAME=217.76.52.157

DEBIAN_FRONTEND=noninteractive
USER=root
TOMCAT_VERSION=9.0.70
WORKON_HOME=~/.virtualenvs
JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre
CONFIG=~/configGeo/config

# --------------------
GIT=https://github.com/quangdaicaa/configGeo.git
KEY_PSQL=https://www.postgresql.org/media/keys/ACCC4CF8.asc
GEOSERVER_FILE=https://artifacts.geonode.org/geoserver/2.19.x/geoserver.war
GEONODE_GIT=https://github.com/GeoNode/geonode.git
TOMCAT_FILE=https://www-eu.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz
GEONODE_FILE=https://artifacts.geonode.org/geoserver/2.19.x/geonode-geoserver-ext-web-app-data.zip
RABBITMQ_SERVER_FILE=https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.deb.sh

$CONFIG/build1.sh

echo "WORKON_HOME=~/.virtualenvs" >> ~/.bashrc
echo "JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre" >> ~/.bashrc
source ~/.bashrc

apt install -y \
  software-properties-common \
  build-essential \
  python3.8-dev python3.8-venv virtualenvwrapper \
  libxml2 libxml2-dev gettext libmemcached-dev zlib1g-dev \
  libxslt1-dev libjpeg-dev libpng-dev libpq-dev \
  unzip gcc zlib1g-dev libgeos-dev libproj-dev \
  sqlite3 spatialite-bin libsqlite3-mod-spatialite libsqlite3-dev \
  neovim wget \
  openjdk-8-jdk-headless default-jdk-headless \
  nginx uwsgi uwsgi-plugin-python3 \
  supervisor \
  memcached \
  libmemcached-dev zlib1g-dev

add-apt-repository -y ppa:ubuntugis/ppa
add-apt-repository -y ppa:certbot/certbot
add-apt-repository -y ppa:rabbitmq/rabbitmq-erlang
cp $CONFIG/pgdg.list /etc/apt/sources.list.d/pgdg.list
wget --no-check-certificate -O - $KEY_PSQL | apt-key add -
wget -qO - $RABBITMQ_SERVER_FILE | sudo bash
apt update
apt install -y --allow-downgrades \
  python3-gdal=3.3.2+dfsg-2~focal2 \
  gdal-bin=3.3.2+dfsg-2~focal2 \
  libgdal-dev=3.3.2+dfsg-2~focal2 \
  postgresql-13 postgresql-13-postgis-3 \
  postgresql-13-postgis-3-scripts postgresql-client-13 \
  python3-certbot-nginx \
  rabbitmq-server
update-java-alternatives --jre-headless --set java-1.8.0-openjdk-amd64
gdalinfo --version
python3.8 --version
which python3.8
java -version

source /usr/share/virtualenvwrapper/virtualenvwrapper.sh
mkvirtualenv --python=/usr/bin/python3.8 geonode
cd /opt
git clone $GEONODE_GIT -b 3.3.x geonode
usermod -a -G www-data $USER
chown -Rf $USER:www-data /opt/geonode
chmod -Rf 775 /opt/geonode
cd /opt/geonode
pip install -r requirements.txt --upgrade
pip install -e . --upgrade
pip install pygdal=="`gdal-config --version`.*"
pip install pylibmc==1.6.1 sherlock==0.3.2
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
cat $CONFIG/pg_hba.conf > /etc/postgresql/13/main/pg_hba.conf
# cp $CONFIG/pg_hba.conf /etc/postgresql/13/main/pg_hba.conf
chmod 640 /etc/postgresql/13/main/pg_hba.conf
service postgresql restart
# psql -U postgres geonode
# psql -U geonode geonode
# psql -U postgres geonode_data
# psql -U geonode geonode_data

# source ~/.virtualenvs/geonode/bin/activate
# service postgresql start

# systemctl restart tomcat9.service
# service postgresql restart