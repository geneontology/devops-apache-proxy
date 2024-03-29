FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux

RUN apt-get update \
    && apt-get install -y apache2 logrotate libapache2-mod-qos \
    && apt-get install -y awscli \
    && apt-get -qq purge && apt-get -qq clean && rm -rf /var/lib/apt/lists/*

RUN echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d \
    && rm -rf /var/log/apache2 \
    && mkdir -p /var/log/apache2 \
    && rm -f /etc/apache2/sites-available/*.conf \
    && rm -f /etc/apache2/sites-enabled/*.conf

RUN a2dismod mpm_event mpm_worker \
    && a2enmod mpm_prefork \
    && a2dismod cgid mpm_event mpm_worker \
    && a2enmod alias mpm_prefork rewrite proxy proxy_http proxy_html macro headers qos ssl

EXPOSE 80
EXPOSE 443 


# used by logrotate-to-s3.sh
ENV S3_PATH=logrotate
ENV S3_BUCKET=bucket
ENV USE_S3=1
ENV USE_SSL=1
ENV S3_SSL_CERTS_LOCATION=s3://replace_me
ENV USE_CLOUDFLARE=0

COPY ./entrypoint-proxy.sh /entrypoint.sh

# COPY ./apache2 /etc/logrotate.d/apache2
COPY ./apache2 /apache2
COPY ./logrotate-to-s3.sh /opt/bin/logrotate-to-s3.sh

# COPY crontab and script to download ssl credentials 
COPY ./crontabs.txt /crontabs.txt
COPY ./download_certs.sh /opt/bin/download_certs.sh 


COPY ./cloudflare /cloudflare

# RUN chmod +x /entrypoint.sh /opt/bin/logrotate-to-s3.sh && chmod 400 /etc/logrotate.d/apache2
RUN chmod +x /entrypoint.sh /opt/bin/logrotate-to-s3.sh /opt/bin/download_certs.sh
ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["tail", "-f", "/dev/null" ]
