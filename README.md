# Apache Proxy with logrotate to s3 bucket

- ENV S3_BUCKET=some_bucket
- ENV USE_S3=1

# Build And Push Image

Clone the repo. 

```sh
# Example: Build and  push to dockerhub geneontology repo.
# Choose appropriate tag if planning to push dockerhub geneontology repo.

docker build -t geneontology/apache-proxy:some_tag . 
docker push geneontology/apache-proxy:some_tag
```
