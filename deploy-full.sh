#!/usr/bin/env bash

# Set namespace for elk
NAMESPACE=logging

kubectl create namespace "$NAMESPACE"

kctl() {
    kubectl --namespace "$NAMESPACE" "$@"
}
# alias kctl='kubectl --namespace logging'

# Deploy Elasticsearch
kctl apply -f es-configmap.yaml
kctl apply -f es-full-svc.yaml
kctl apply -f es-full.yaml
#improve, but it does not work at this moment. Try in the future
#kubectl wait --for=condition=Ready statefulset/es-full
#Pod Disruption
kctl apply -f es-pdb.yaml


#Deploy Kibana
kctl apply -f kibana-configmap.yaml
kctl apply -f kibana-svc.yaml
kctl apply -f kibana.yaml

echo "done!"
echo "remember create the secret!"
