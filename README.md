# httpservice-python
HTTP Service written in python3 and flask. Ready to be hosted on k8s with ingress-nginx.

## Pre-requisites:

This project is tested on below configuration, you might need to do some adjustments if your configuration differs.

- OS: Debian GNU/Linux 11
- Non-root user with sudo access to install minikube
- Docker Version: 20.10.5+ (non-root user should be able to use docker commands without sudo)
- kubectl v1.23+

## Project Structure

- `resources` directory contains the application code that will be used by the `Dockerfile`.
- `k8s` directory contains the manifests for deployment, service and ingress to be used by Kubernetes.
- `bootstrap.sh` script to bootstrap the `minikube` testing environment with `nginx-ingress` addon enabled.
- `deploy.sh` script to deploy the k8s manifests in one shot on `minikube` kubernetes cluster.

### Instructions to build the application

To build the application in a container image, please issue below command:

```bash
docker build -t httpservice:latest .
```

You will see output like this:

```bash
Sending build context to Docker daemon  90.11kB
Step 1/6 : FROM python:3.9.13-alpine
 ---> b908778bd1b0
Step 2/6 : WORKDIR /python-docker
 ---> Using cache
 ---> aeaf472495ff
Step 3/6 : COPY resources/* ./
 ---> Using cache
 ---> c149bbd4ee05
Step 4/6 : RUN pip3 install -r requirements.txt
 ---> Using cache
 ---> 1efc3454f913
Step 5/6 : ENV FLASK_APP=httpService.py
 ---> Using cache
 ---> 6cce8dbffca7
Step 6/6 : CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0"]
 ---> Using cache
 ---> ec53334da30f
Successfully built ec53334da30f
Successfully tagged httpservice:latest
```

I have further tagged and pushed this image to my personal repository (link) which is then being used in the Kubernetes cluster deployed in further steps.

### Instructions to bootstrap the testing environment

Provided your system already satisfies the `Pre-requisites` requirements stated at the beginning, please issue below command to automatically download, install and start a `minikube` cluster and enable the `ingress` addon on it.

Please note that it will automatically wait for the `nginx-ingress-controller` pod to get ready, so please wait for the script to complete.

```bash
./bootstrap.sh
```

### Instructions to deploy the application on minikube

Please issue below command to automatically deploy the Kubernetes manifests on your minikube cluster:

```bash
./deploy.sh
```

As you can see, in the end it asked you to do a host file entry as we are not using `LoadBalancer` services because we are using a `minikube` cluster. You can either do that by yourself manually or issue below command to take care of that:

```bash
echo "`minikube ip` time-hostname.info" | sudo tee -a /etc/hosts  
```

### Test the application

To test your application from command line itself using curl, use below commands:

```bash
curl time-hostname.info/timestamp


curl time-hostname.info/hostname

```

