#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Usage: $0 <replicaset-name> <namespace>"
    exit 1
fi

REPLICASET_NAME=$1
NAMESPACE=$2
TIMEOUT=300
INTERVAL=5

echo "Waiting for replicaset $REPLICASET_NAME in namespace $NAMESPACE to be ready..."

timeout() {
    local timeout=$1
    local cmd="$2"
    local start_time=$(date +%s)
    
    while true; do
        if [ $(($(date +%s) - start_time)) -ge $timeout ]; then
            echo "Timeout waiting for replicaset to be ready"
            return 1
        fi
        
        if $cmd; then
            return 0
        fi
        
        sleep $INTERVAL
    done
}

check_replicaset() {
    local replicas=$(kubectl get replicaset $REPLICASET_NAME -n $NAMESPACE -o jsonpath='{.spec.replicas}' 2>/dev/null)
    local ready_replicas=$(kubectl get replicaset $REPLICASET_NAME -n $NAMESPACE -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
    
    if [ -z "$replicas" ]; then
        return 1
    fi
    
    if [ -z "$ready_replicas" ]; then
        ready_replicas=0
    fi
    
    if [ "$replicas" = "$ready_replicas" ]; then
        return 0
    fi
    
    return 1
}

if timeout $TIMEOUT "check_replicaset"; then
    echo "ReplicaSet $REPLICASET_NAME is ready!"
else
    echo "ReplicaSet $REPLICASET_NAME failed to become ready within $TIMEOUT seconds"
    exit 1
fi 
