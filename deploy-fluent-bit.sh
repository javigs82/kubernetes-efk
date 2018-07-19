#!/usr/bin/env bash

# Set namespace for elk
NAMESPACE=logging


kctl() {
    kubectl --namespace "$NAMESPACE" "$@"
}
# alias kctl='kubectl --namespace logging'

#
#Fluent Bit must be deployed as a DaemonSet
# Create service account and roles
kctl apply -f fluent-bit-service-account.yaml
kctl apply -f fluent-bit-role.yaml
kctl apply -f fluent-bit-role-binding.yaml

#Create config map
kctl apply -f fluent-bit-configmap.yaml

#Create Daemon Set
kctl apply -f fluent-bit-ds.yaml

echo "done!"
