# n8n Dockerfile Sample
The files in this repository are almost the same as those at the following URL.
https://github.com/n8n-io/n8n/blob/master/docker/images/n8n/Dockerfile

## example for deploying cloud run
### build and push to artifact registry
1. make a repository in artifact registry.
2. build the files on local.</br>
    docker build -t {region}-docker.pkg.dev/{gcp project id}/{artifact registry name}/n8n --platform amd64 .
3. push to the repository</br>
    docker push {region}-docker.pkg.dev/{gcp project id}/{artifact registry name}/n8n

### deploy cloud run
operate in GUI
1. select a container image in artifact registry
2. set a port(5678)
3. set postgresql variables
4. "CPU Allocation and Pricing" checks "CPU is always allocated"
5. "Autoscaling" sets 1 in Minimum number of instances
6. another settings are default
