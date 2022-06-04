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
- `bootstrap.sh` script to bootstrap the `minikube` testing environment with `ingress` and `metrics-server` addons enabled.
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

Provided your system already satisfies the `Pre-requisites` requirements stated at the beginning, please issue below command to automatically download, install and start a `minikube` cluster and enable the `ingress` and `metrics-server` addons on it.

Please note that it will automatically wait for the `nginx-ingress-controller` pod to get ready, so please wait for the script to complete.

```bash
./bootstrap.sh
```
It should return something like this:

```bash
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 69.2M  100 69.2M    0     0   218M      0 --:--:-- --:--:-- --:--:--  218M
😄  minikube v1.25.2 on Debian 11.3 (amd64)
✨  Using the docker driver based on existing profile
👍  Starting control plane node minikube in cluster minikube
🚜  Pulling base image ...
🏃  Updating the running docker "minikube" container ...
🐳  Preparing Kubernetes v1.23.3 on Docker 20.10.12 ...
    ▪ kubelet.housekeeping-interval=5m
🔎  Verifying Kubernetes components...
    ▪ Using image gcr.io/k8s-minikube/storage-provisioner:v5
🌟  Enabled addons: default-storageclass, storage-provisioner
🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
    ▪ Using image k8s.gcr.io/ingress-nginx/controller:v1.1.1
    ▪ Using image k8s.gcr.io/ingress-nginx/kube-webhook-certgen:v1.1.1
    ▪ Using image k8s.gcr.io/ingress-nginx/kube-webhook-certgen:v1.1.1
🔎  Verifying ingress addon...
🌟  The 'ingress' addon is enabled
    ▪ Using image k8s.gcr.io/metrics-server/metrics-server:v0.4.2
🌟  The 'metrics-server' addon is enabled
pod/ingress-nginx-controller-cc8496874-cgxv5 condition met
```

### Instructions to deploy the application on minikube

Please issue below command to automatically deploy the Kubernetes manifests on your minikube cluster:

```bash
./deploy.sh
```

You will see something similar to this:

```bash
deployment.apps/python-deployment created
horizontalpodautoscaler.autoscaling/python-hpa created
ingress.networking.k8s.io/python-ingress created
service/python-service created

 Deployment completed. Sleeping for 10s until IP is assigned to ingress resource...

 Deployment completed. Sleeping for 10s until IP is assigned to ingress resource...

 Deployment completed. Sleeping for 10s until IP is assigned to ingress resource...

 Deployment completed. Sleeping for 10s until IP is assigned to ingress resource...

 Deployment ready now. Please update your hosts file with below entry:
 
 192.168.49.2 time-hostname.info
 ```

As you can see, in the end it asked you to do a host file entry as we are not using `LoadBalancer` services because we are using a `minikube` cluster. You can either do that by yourself manually or issue below command to take care of that:

```bash
echo "`minikube ip` time-hostname.info" | sudo tee -a /etc/hosts  
```

### Test the application

To test your application from command line itself using curl, use below commands:

For timestamp:

```bash
curl time-hostname.info/timestamp
```

It will return the timestamp like this:

```bash
1654327983.8266492
```

Then, for hostname:

```bash
curl time-hostname.info/hostname
```

It will return hostname (in our case, pod's name) like this:

```bash
"python-deployment-7b7954c4fc-dghlf"
```

As of now, you will see only one replica. But if you keep on hitting the api using some script to increase the cpu/memory load. It will automatically scale up the replica set to a maximum of 3 using the `hpa`.