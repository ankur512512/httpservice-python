#!/bin/bash

kubectl apply -f k8s

until [[ $(kubectl get ingress python-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}') ]]
do
echo -e "\n Deployment completed. Sleeping for 10s until IP is assigned to ingress resource..."
sleep 10
done

echo -e "\n Deployment ready now. Please update your hosts file with this entry:\n `minikube ip` time-hostname.info"
