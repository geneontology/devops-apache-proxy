#!/bin/bash

USE_SSL="${USE_SSL:=1}"

if [ $USE_SSL -ne 0 ]; then
   if [ ! -f "/download_certs_source.sh " ]; then
      echo S3_SSL_CERTS_LOCATION=$S3_SSL_CERTS_LOCATION > /download_certs_source.sh 
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

       if [ ! -f "/logrotate_source.sh " ]; then
          echo S3_BUCKET=$S3_BUCKET > /logrotate_source.sh 
          echo S3_PATH=$S3_PATH >> /logrotate_source.sh 
       fi
   fi
fi

USE_CLOUDFLARE="${USE_CLOUDFLARE:=1}"

if [ $USE_CLOUDFLARE -ne 0 ]; then
   if [ -f "/cloudflare/apache2.conf" ]; then
       cp /cloudflare/apache2.conf /etc/apache2/apache2.conf
       chmod 400 /etc/apache2/apache2.conf
       cp /cloudflare/remoteip.conf /etc/apache2/conf-enabled/remoteip.conf
       chmod 400 /etc/apache2/conf-available/remoteip.conf 
   fi

   a2enmod remoteip
fi


echo " Restart apache service." 
service apache2 restart

exec "$@"
