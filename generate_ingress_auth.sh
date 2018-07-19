#!/bin/bash
if [[ $# -eq 0 ]] ; then
    echo "Run the script with the required auth user and namespace for the secret: ${0} [user] [namespace]"
    exit 0
fi
htpasswd -c auth ${1} && \
kubectl delete secret -n ${2} basic-auth

kubectl create secret generic basic-auth --from-file=auth -n ${2}

#rm auth.tmp
