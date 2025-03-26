# try-k8s

## Util Commands

- Debug Helm output
  - `helm template ./ -f ./values.yaml --debug > ./output.yaml`
- Get ArgoCD admin password
  - `kubectl -n argocd get secret/argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`
- Delete environment
  - `minikube delete --all --purge`
