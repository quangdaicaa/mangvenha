#!/usr/bin/bash

useradd -m -U -d /opt/tomcat -s /bin/bash tomcat
usermod -a -G www-data tomcat
mkdir -p /opt/tomcat
wget $TOMCAT_FILE
tar -xvf apache-tomcat-${TOMCAT_VERSION}.tar.gz -C /opt/tomcat
rm apache-tomcat-${TOMCAT_VERSION}.tar.gz
mv /opt/tomcat/apache-tomcat-${TOMCAT_VERSION} /opt/tomcat/latest
chown -R tomcat:www-data /opt/tomcat
chmod +x /opt/tomcat/latest/bin/*.sh
ln -s $JAVA_HOME /usr/lib/jvm/jre
echo $JAVA_HOME
cp $CONFIG/tomcat9_etc.service /etc/systemd/system/tomcat9.service
cp $CONFIG/tomcat9_usr.service /usr/lib/systemd/system/tomcat9.service
systemctl daemon-reload
systemctl enable tomcat9.service
systemctl start tomcat9.service
ss -ltn
ufw allow 8080/tcp
mkdir -p /opt/data/logs
mkdir -p /opt/data/geoserver_logs
mkdir -p /opt/data/gwc_cache_dir
wget --no-check-certificate $GEONODE_FILE
unzip geonode-geoserver-ext-web-app-data.zip -d /opt/data/
rm geonode-geoserver-ext-web-app-data.zip
mv /opt/data/data /opt/data/geoserver_data
chown -Rf $USER:www-data /opt/data
chown -Rf $USER:www-data /opt/data/logs
chown -Rf tomcat:www-data /opt/data/geoserver_data
chown -Rf tomcat:www-data /opt/data/geoserver_logs
chown -Rf tomcat:www-data /opt/data/gwc_cache_dir
chmod -Rf 775 /opt/data/geoserver_logs
chmod -Rf 775 /opt/data/gwc_cache_dir
chmod -Rf 775 /opt/data/geoserver_data
chmod -Rf 775 /opt/data
chmod -Rf 775 /opt/data/logs
cd /opt/tomcat/latest/webapps
wget --no-check-certificate $GEOSERVER_FILE -O geoserver.wa
sed -i -e 's/xom-\*\.jar/xom-\*\.jar,bcprov\*\.jar/g' /opt/tomcat/latest/conf/catalina.properties
cp $CONFIG/setenv.sh /opt/tomcat/latest/bin/setenv.sh
# export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")
# echo 'JAVA_HOME='$JAVA_HOME | sudo tee --append /opt/tomcat/latest/bin/setenv.sh
# sudo sed -i -e "s/JAVA_OPTS=/#JAVA_OPTS=/g" /opt/tomcat/latest/bin/setenv.sh
# echo 'GEOSERVER_DATA_DIR="/opt/data/geoserver_data"' | sudo tee --append /opt/tomcat/latest/bin/setenv.sh
# echo 'GEOSERVER_LOG_LOCATION="/opt/data/geoserver_logs/geoserver.log"' | sudo tee --append /opt/tomcat/latest/bin/setenv.sh
# echo 'GEOWEBCACHE_CACHE_DIR="/opt/data/gwc_cache_dir"' | sudo tee --append /opt/tomcat/latest/bin/setenv.sh
# echo 'GEOFENCE_DIR="$GEOSERVER_DATA_DIR/geofence"' | sudo tee --append /opt/tomcat/latest/bin/setenv.sh
# echo 'TIMEZONE="UTC"' | sudo tee --append /opt/tomcat/latest/bin/setenv.sh
# echo 'JAVA_OPTS="-server -Djava.awt.headless=true -Dorg.geotools.shapefile.datetime=false -XX:+UseParallelGC -XX:ParallelGCThreads=4 -Dfile.encoding=UTF8 -Duser.timezone=$TIMEZONE -Xms512m -Xmx4096m -Djavax.servlet.request.encoding=UTF-8 -Djavax.servlet.response.encoding=UTF-8 -DGEOSERVER_CSRF_DISABLED=true -DPRINT_BASE_URL=http://localhost:8080/geoserver/pdf -DGEOSERVER_DATA_DIR=$GEOSERVER_DATA_DIR -Dgeofence.dir=$GEOFENCE_DIR -DGEOSERVER_LOG_LOCATION=$GEOSERVER_LOG_LOCATION -DGEOWEBCACHE_CACHE_DIR=$GEOWEBCACHE_CACHE_DIR"' | sudo tee --append /opt/tomcat/latest/bin/setenv.sh
# source /opt/tomcat/latest/bin/setenv.sh

cp $CONFIG/$NAME/geonode.ini /etc/uwsgi/apps-available/geonode.ini
ln -s /etc/uwsgi/apps-available/geonode.ini /etc/uwsgi/apps-enabled/geonode.ini
pkill -9 -f uwsgi
cp $CONFIG/geonode-uwsgi-start.sh /usr/bin/geonode-uwsgi-start.sh
chmod +x /usr/bin/geonode-uwsgi-start.sh
cp $CONFIG/geonode-uwsgi.service /etc/systemd/system/geonode-uwsgi.service
systemctl daemon-reload
systemctl enable geonode-uwsgi.service
systemctl start geonode-uwsgi.service

# --------------------
mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.orig
rm /etc/nginx/sites-enabled/default
cp $config/nginx.conf /etc/nginx/nginx.conf
cp $config/$NAME/geonode /etc/nginx/sites-available/geonode
mkdir -p /opt/geonode/geonode/uploaded
chown -Rf tomcat:www-data /opt/geonode/geonode/uploaded
chmod -Rf 777 /opt/geonode/geonode/uploaded
touch /opt/geonode/geonode/.celery_results
chmod 777 /opt/geonode/geonode/.celery_results
ln -s /etc/nginx/sites-available/geonode /etc/nginx/sites-enabled/geonode

service tomcat9 restart
service nginx restart
workon geonode
cd /opt/geonode
chmod +x *.sh
./paver_local.sh reset
./paver_local.sh setup
./paver_local.sh sync
./manage_local.sh collectstatic --noinput
chmod -Rf 777 geonode/static_root/ geonode/uploaded/
service tomcat9 restart
pkill -9 -f uwsgi
cd /opt/geonode
cp package/support/geonode.binary /usr/bin/geonode
cp package/support/geonode.updateip /usr/bin/geonode_updateip
chmod +x /usr/bin/geonode
chmod +x /usr/bin/geonode_updateip
source .env_local
touch /opt/geonode/geonode/wsgi.py
PYTHONWARNINGS=ignore VIRTUAL_ENV=$VIRTUAL_ENV DJANGO_SETTINGS_MODULE=geonode.settings GEONODE_ETC=/opt/geonode/geonode GEOSERVER_DATA_DIR=/opt/data/geoserver_data TOMCAT_SERVICE="service tomcat9" APACHE_SERVICE="service nginx" geonode_updateip -p localhost
PYTHONWARNINGS=ignore VIRTUAL_ENV=$VIRTUAL_ENV DJANGO_SETTINGS_MODULE=geonode.local_settings GEONODE_ETC=/opt/geonode/geonode GEOSERVER_DATA_DIR=/opt/data/geoserver_data TOMCAT_SERVICE="service tomcat" APACHE_SERVICE="service nginx" geonode_updateip -l localhost -p $NAME
DJANGO_SETTINGS_MODULE=geonode.local_settings python manage.py migrate_baseurl --source-address=http://$NAME --target-address=http://$NAME
systemctl reload nginx
ufw allow 'Nginx Full'
ufw delete allow 'Nginx HTTP'
certbot --nginx -d example.org -d $NAME
rabbitmq-plugins enable rabbitmq_management
ufw allow proto tcp from any to any port 5672,15672
rabbitmqctl delete_user guest
rabbitmqctl add_user admin <your_rabbitmq_admin_password_here>
rabbitmqctl set_user_tags admin administrator
rabbitmqctl add_vhost /localhost
rabbitmqctl set_permissions -p / admin ".*" ".*" ".*"
rabbitmqctl set_permissions -p /localhost admin ".*" ".*" ".*"
systemctl restart rabbitmq-server
rabbitmqctl reset
mkdir /etc/supervisor
echo_supervisord_conf > /etc/supervisor/supervisord.conf
mkdir /etc/supervisor/conf.d
cp $CONFIG/supervisord.conf /etc/supervisor/supervisord.conf
cp $CONFIG/geonode-celery.conf /etc/supervisor/conf.d/geonode-celery.conf
supervisorctl reload
systemctl restart supervisor
pkill -f celery
systemctl enable memcached
systemctl start memcached
systemctl restart supervisor.service

cd ~