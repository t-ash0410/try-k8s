#!/bin/bash

__LOCAL_PORT=8081

kubectx minikube

if [ $? -ne 0 ]; then
    echo "Error occurred while executing 'kubectx minikube'"
    exit 1
fi

argo_server=$(kubectl get replicaset -n argocd | grep argocd-server | awk '{print $1}')

######################### Use ArgoCD #########################

kubectl port-forward -n argocd replicaset/$argo_server $__LOCAL_PORT:8080 &
pf=$!

for ((i=0 ; i<20 ; i++)); do
    sleep 0.1
    if [ `ps -p $pf -o state | tail -n 1` != "S+" ]; then
        continue
    fi
done

######################### Add Repository #########################

argocd login --insecure localhost:8081

argocd repo add https://github.com/t-ash0410/try-k8s.git \
  --username $GITHUB_USER \
  --password $GITHUB_PAT

######################### Apply Bootstrap #########################

kubectl apply -f ./bootstrap.yaml

kill $pf
