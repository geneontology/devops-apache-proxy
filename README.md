# Apache Proxy with support for https and logrotate to s3 bucket

Logrotate:

- ENV USE_S3=1
- ENV S3_BUCKET=some_bucket
- ENV S3_PATH=someupo

HTTPS:

- ENV USE_SSL=1
- ENV S3_SSL_CERTS_LOCATION=s3://replace_me



# Build And Push Image

Clone the repo. 

```sh
# Example: Build and  push to dockerhub geneontology repo.
# Choose appropriate tag if planning to push dockerhub geneontology repo.

docker build -t geneontology/apache-proxy:some_tag . 
docker push geneontology/apache-proxy:some_tag
```

# Testing Logrorate


```
# Make sure aws credentials are configured
echo $S3_BUCKET
aws s3 ls s3://$S3_BUCKET
logrotate -v -f /etc/logrotate.d/apache2
cat /tmp/logrotate-to-s3.log 
```
