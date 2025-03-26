# try-k8s

This repository is created for learning and experimenting with ArgoCD and Istio in a local Kubernetes environment.

## Overview

This project demonstrates:

- GitOps workflow using ArgoCD
- Service mesh implementation with Istio
- Local Kubernetes development using Minikube

## Prerequisites

- [Minikube](https://minikube.sigs.k8s.io/docs/start/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [Helm](https://helm.sh/docs/intro/install/)
- [Nix](https://nixos.org/download.html) (recommended)
- [direnv](https://direnv.net/) (recommended)

## Getting Started

### Option 1: Using Nix with direnv (Recommended)

This project provides a development environment using Nix flakes. This is the recommended way to get started.

- Copy `.envrc.sample` to `.envrc` and configure your GitHub credentials

  ```bash
  cp .envrc.sample .envrc
  ```

- Edit `.envrc` and set your GitHub credentials:
  - `GITHUB_USER`: Your GitHub username
  - `GITHUB_PAT`: Your GitHub Personal Access Token

- Allow direnv to load the environment

  ```bash
  direnv allow
  ```

- Run the setup script

  ```bash
  cd ./k8s/argocd/bootstrap
  ./k8s/argocd/bootstrap/setup.sh
  ```

### Option 2: Manual Setup

If you prefer to set up manually or don't use Nix:

- Start Minikube cluster

  ```bash
  minikube start
  ```

- Enable required addons

  ```bash
  minikube addons enable ingress
  ```

- Install ArgoCD

  ```bash
  kubectl create namespace argocd
  kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
  ```

- Install Istio

  ```bash
  helm repo add istio https://istio-release.storage.googleapis.com/charts
  helm repo update
  kubectl create namespace istio-system
  helm install istio-base istio/base -n istio-system
  helm install istiod istio/istiod -n istio-system
  ```

- Access ArgoCD UI

  ```bash
  kubectl port-forward svc/argocd-server -n argocd 8080:443
  ```

Then visit: https://localhost:8080

## Util Commands

- Debug Helm output

  - `helm template ./ -f ./values.yaml --debug > ./output.yaml`

- Get ArgoCD admin password

  - `kubectl -n argocd get secret/argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`

- Delete environment

  - `minikube delete --all --purge`

## Project Structure

```txt
.
├── flake.nix              # Nix development environment configuration
├── k8s/
│   ├── argocd/           # ArgoCD configuration
│   │   ├── bootstrap/    # Bootstrap scripts and manifests
│   │   └── apps/         # Application manifests
│   └── istio/            # Istio configuration
└── values.yaml           # Helm values file
```

The project is organized to demonstrate GitOps practices with ArgoCD and service mesh implementation with Istio. The `k8s/argocd/bootstrap` directory contains scripts and manifests for initial setup, while `k8s/argocd/apps` contains the application manifests that will be managed by ArgoCD.
