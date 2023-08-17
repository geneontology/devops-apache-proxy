#!/bin/bash

echo `date`
source /download_certs_source.sh
DESTINATION=/tmp/ssl-credentials.tar.gz
TAR_DESTINATION=/tmp/ssl-certs

mkdir -p /opt/credentials

SLEEP_DURATION=5
tries=3
i=0

while true 
   do
     echo  "Downloading ssl credentials from $S3_SSL_CERTS_LOCATION Try: $i ..."
     aws s3 cp $S3_SSL_CERTS_LOCATION $DESTINATION
     ret=$?

     if [ $ret != 0 ]; then
        echo  "Error dowloading ssl credentials from S3_SSL_CERTS_LOCATION=$S3_SSL_CERTS_LOCATION"
     else
	break
     fi

     ((i++))

     if [ $i -lt $tries ]; then
        echo  "Going to sleep for $SLEEP_DURATION ..."
        sleep $SLEEP_DURATION 
     else
        echo  "Giving up on downloading ssl credentials from $S3_SSL_CERTS_LOCATION ..."
	exit 1
     fi
done

rm -rf $TAR_DESTINATION
mkdir -p $TAR_DESTINATION
tar -xzf $DESTINATION -C $TAR_DESTINATION 
cert_file=`find $TAR_DESTINATION -name fullchain.pem`
key_file=`find $TAR_DESTINATION -name privkey.pem`

if [ ! -f "$cert_file" ]; then
   echo "Did not find cert file. Exiting ..."
   rm -rf $TAR_DESTINATION
   rm -rf $DESTINATION
   exit 2 
fi

echo diff $cert_file /opt/credentials/fullchain.pem
diff $cert_file /opt/credentials/fullchain.pem > /dev/null 2>&1
ret=$?

if [ $ret = 0 ]; then
   echo  "Ssl credentials are sane. Doing nothing..."
else
   echo  "Copying ssl credentials ..."
   cp $cert_file /opt/credentials
   cp $key_file /opt/credentials
   chmod 400 /opt/credentials/fullchain.pem
   chmod 400 /opt/credentials/privkey.pem
   echo  "Reloading apache service ..."
   /usr/sbin/service apache2 reload > /dev/null 
fi
rm -rf $TAR_DESTINATION
rm -rf $DESTINATION
exit 0 
