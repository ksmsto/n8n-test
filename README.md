# n8n Dockerfile Sample
The files in this repository are almost the same as those at the following URL.
https://github.com/n8n-io/n8n/blob/master/docker/images/n8n/Dockerfile

## example for deploying cloud run
### create a bucket in cloud storage 
1. make a bucket in cloud storage
2. set location type "Region"
3. set storage class "Autoclass"
4. set access control "Private"

### build and push to artifact registry
1. make a repository in artifact registry.
2. build the files on local.</br>
    docker build -t {region}-docker.pkg.dev/{gcp project id}/{artifact registry name}/n8n:{tag} --platform amd64 .
3. push to the repository</br>
    docker push {region}-docker.pkg.dev/{gcp project id}/{artifact registry name}/n8n:{tag}

### deploy cloud run
operate in GUI
1. select a container image in artifact registry
2. set a port(5678)
3. set storage url(GCS_BUCKET_URL), which you create a bucket. (ex. gcs://${bucket name}/database.sqlite)
4. set n8n encryption key(N8N_ENCRYPTION_KEY), which you want
5. "CPU Allocation and Pricing" checks "CPU is always allocated"
6. "Autoscaling" sets 1 in Minimum number of instances
7. another settings are default
