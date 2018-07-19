#!/usr/bin/env bash

# Set namespace for elk
NAMESPACE=logging

kubectl create namespace "$NAMESPACE"

kctl() {
    kubectl --namespace "$NAMESPACE" "$@"
}
# alias kctl='kubectl --namespace logging'

# Deploy Elasticsearch service
kctl apply -f es-configmap.yaml

# Deploy Elasticsearch master node and wait until it's up
kctl apply -f es-full.yaml

# Deploy Elasticsearch data node and wait until it's up
kctl apply -f es-full-svc.yaml


# Deploy Kibana
kctl apply -f kibana-configmap.yaml
kctl apply -f kibana-svc.yaml
kctl apply -f kibana.yaml

echo "done!"
echo "remember create the secret!"