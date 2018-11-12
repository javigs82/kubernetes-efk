# K8S EFK
ElasticFluentbitKibana stack deployment on top of kubernetes infrastructure built in fluent bit  
Note that it should work on minikube.

### Deployment
The deployment is done on the “logging” namespace and there is a script to automate it and tear it down. 
There are a set of manifest (`es-full.yaml`,`es-full-svc.yaml`) to deploy a three-node (could be changed in the `replicas` parameter) scenario where every node contains all functionality (master, data and ingest).


### Minikube
Minikube must be started with at least 6 GB RAM and 3 cpus in order to mimic production envs.

```shell
minikube start --vm-driver kvm2 --memory 6144 --cpus 3
```

## Notes

* The data pods are deployed as a `StatefulSet`. These use a `volumeClaimTemplates` to provision persistent storage for each pod.

* The number of replicas per node should be set up in function of ecosystem's requirements. Just adjust `spec.replicas` in deployment specification files.

## Pre-requisites

* `minikube` installed.

* `kubectl` configured to access the cluster master API Server.

## Build images

The project uses base images provided by elastic [Docker @ Elastic](https://www.docker.elastic.co/).

## Deploy

Use the `deploy-full.sh` script or follow it manually (these commands deploy the full stack).


Create the namespace and the configuration:

```
kubectl create namespace logging
alias kctl='kubectl --namespace logging'

kctl apply -f es-configmap.yaml
```

To have a three-node cluster with all roles, use this:

```
kctl apply -f es-full-svc.yaml
kctl apply -f es-full.yaml
```

Create the ingress auth:

```
sh generate_ingress_auth.sh [user] [namespace]
```

For local purpose, remember modify /etc/hosts to point to your minikube ip:

```
vi /etc/hosts 
```

## Service and Ingress
There are three services on the stack, one for Kibana web interface, one for ElasticSearch API interface on port 9200 and the last one for ElasticSearch internal node communication on port 9300.

To accompany the services, there are two ingress-nginx that allow external access to the stack. One for Kibana web interface, and another for ElasticSearch API. 
Adjust the domains and need for these ingresses according to the proper environment.


### Access the service

*Don't forget* that services in Kubernetes are only acessible from containers in the cluster. For different behavior one should [configure the creation of an external load-balancer](https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer) or use an ingress as currently included in the project.

*Note:* if you are using one of the cloud providers which support external load balancers, setting the type field to "LoadBalancer" will provision a load balancer for your Service. You can uncomment the field in `es-svc.yaml`.

## Availability

If one wants to ensure that no more than `n` Elasticsearch nodes will be unavailable at a time, one can optionally (change and) apply the following manifests:
```
kubectl create -f es-master-pdb.yaml
kubectl create -f es-data-pdb.yaml
```

## Kibana

Additionally, one can also add Kibana to the mix. In order to do so, one can use the Elastic upstream open source docker image without x-pack.

### Deploy

```
kctl apply -f kibana-configmap.yaml
kctl apply -f kibana-svc.yaml
kctl apply -f kibana.yaml
```
There is also an Ingress-Nginx to expose the service publicly or simply use the service nodeport.
In the case one proceeds to do so, one must change the environment variable `server.basePath` in `kibana-config-map.yaml` to the match their environment.

## Fluent Bit

[Fluent Bit](http://fluentbit.io) is a lightweight and extensible __Log Processor__ that comes with full support for Kubernetes:
It must be deployed as a DaemonSet, so on that way it will be available on every node of your Kubernetes cluster. To get started run the following commands to create the namespace, service account and role setup:

```
kctl apply -f fluent-bit-service-account.yaml
kctl apply -f fluent-bit-role.yaml 
kctl apply -f fluent-bit-role-binding.yaml
kctl apply -f fluent-bit-configmap.yaml
kctl apply -f fluent-bit-ds.yaml
```
Repo also contains fluent-bit for minikube `fluent-bit-ds-minikube.yaml`

## FAQ

### Why does `NUMBER_OF_MASTERS` differ from number of master-replicas?
The default value for this environment variable is 2, meaning a cluster will need a minimum of 2 master nodes to operate. If a cluster has 3 masters and one dies, the cluster still works. Minimum master nodes are usually `n/2 + 1`, where `n` is the number of master nodes in a cluster. If a cluster has 5 master nodes, one should have a minimum of 3, less than that and the cluster _stops_. If one scales the number of masters, make sure to update the minimum number of master nodes through the Elasticsearch API as setting environment variable will only work on cluster setup. More info: https://www.elastic.co/guide/en/elasticsearch/guide/1.x/_important_configuration_changes.html#_minimum_master_nodes


### How can I customize `elasticsearch.yaml`?
Read a different config file by settings env var `ES_PATH_CONF=/path/to/my/config/` [(see the Elasticsearch docs for more)](https://www.elastic.co/guide/en/elasticsearch/reference/current/settings.html#config-files-location) or edit the provided ConfigMap.

## Acknowledges
This repo is a customization of a [@pires' project](https://github.com/pires/kubernetes-elasticsearch-cluster) published in github. Thanks for this amazing job.


