#!/bin/bash

LOCAL_PORT=8081

######################### Start Minikube #########################

# If an error occurs, you might want to check this issue.
# https://github.com/kubernetes/minikube/issues/12274#issuecomment-1006201978
minikube start

######################### Setup ArgoCD #########################

kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

######################### Port Forwarding #########################

ARGOCD_SERVER=$(kubectl get replicaset -n argocd | grep argocd-server | awk '{print $1}')

./wait-for-replicaset.sh $ARGOCD_SERVER argocd

kubectl port-forward -n argocd replicaset/$ARGOCD_SERVER $LOCAL_PORT:8080 &
pf=$!

for ((i=0 ; i<20 ; i++)); do
    sleep 0.1
    if [ `ps -p $pf -o state | tail -n 1` != "S+" ]; then
        continue
    fi
done

######################### Get Admin Password #########################

ADMIN_SECRET=$(kubectl -n argocd get secret/argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "ArgoCD admin password: $ADMIN_SECRET"

######################### Login #########################

argocd login --insecure localhost:8081

######################### Add Repository #########################

argocd repo add https://github.com/t-ash0410/try-k8s.git \
  --username $GITHUB_USER \
  --password $GITHUB_PAT

######################### Apply Bootstrap #########################

kubectl apply -f ./argocd.yaml

kill $pf
