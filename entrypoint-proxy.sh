#!/bin/bash

USE_SSL="${USE_SSL:=1}"

if [ $USE_SSL -ne 0 ]; then
   if [ ! -f "/download_certs_source.sh " ]; then
      echo S3_SSL_CERTS_LOCATION=$S3_SSL_CERTS_LOCATION > download_certs_source.sh 
   fi

   if [ -f "/crontabs.txt" ]; then
      echo " Installing crontabs ..." 
      crontab /crontabs.txt 
      rm /crontabs.txt
   fi
   echo "Dowloading ssl credentials ..." 
   /opt/bin/download_certs.sh >> /tmp/download_certs.log 2>&1
fi

echo " Restart cron ...." 
service cron restart

USE_S3="${USE_S3:=1}"

if [ $USE_S3 -ne 0 ]; then
   if [ -f "/apache2" ]; then
       mv /apache2 /etc/logrotate.d/apache2
       chmod 400 /etc/logrotate.d/apache2
   fi
fi

echo " Restart apache service." 
service apache2 restart

exec "$@"
