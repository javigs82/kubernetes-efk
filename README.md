# K8S EFK
<<<<<<< HEAD
EFK stack deployment in kubernetes and built with fluent bit  
=======
ElasticFluentbitKibana stack deployment on top of kubernetes infrastructure built in fluent bit  
Note that it should work on minikube.
>>>>>>> bafc45ad720d4fb168272beb6d6a2af0e624baae

### Deployment
The deployment is done on the “logging” namespace and there is a script to automate it and tear it down. 
There are a set of manifest (`es-full.yaml`,`es-full-svc.yaml`) to deploy a three-node (could be changed in the `replicas` parameter) scenario where every node contains all functionality (master, data and ingest).

Note that it should work on minikube.


### Minikube
Minikube must be started with at least 6 GB RAM and 3 cpus in order to mimic production envs.

```shell
minikube start --vm-driver kvm2 --memory 6144 --cpus 3
```

## Notes

* The data pods are deployed as a `StatefulSet`. These use a `volumeClaimTemplates` to provision persistent storage for each pod.

<<<<<<< HEAD
=======
* The number of replicas per node should be set up in function of ecosystem's requirements. Just adjust `spec.replicas` in deployment specification files.

>>>>>>> bafc45ad720d4fb168272beb6d6a2af0e624baae
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

To have a full cluster with all roles, use this:

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

*Note:* if you are using one of the cloud providers which support external load balancers, setting the type field to "LoadBalancer" will provision a load balancer for your Service.

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

## Troubleshooting

### No up-and-running site-local

One of the errors one may come across when running the setup is the following error:
```
[2018-08-29T01:28:36,515][WARN ][o.e.b.ElasticsearchUncaughtExceptionHandler] [] uncaught exception in thread [main]
org.elasticsearch.bootstrap.StartupException: java.lang.IllegalArgumentException: No up-and-running site-local (private) addresses found, got [name:lo (lo), name:eth0 (eth0)]
	at org.elasticsearch.bootstrap.Elasticsearch.init(Elasticsearch.java:116) ~[elasticsearch-5.0.1.jar:5.0.1]
	at org.elasticsearch.bootstrap.Elasticsearch.execute(Elasticsearch.java:103) ~[elasticsearch-5.0.1.jar:5.0.1]
	at org.elasticsearch.cli.SettingCommand.execute(SettingCommand.java:54) ~[elasticsearch-5.0.1.jar:5.0.1]
	at org.elasticsearch.cli.Command.mainWithoutErrorHandling(Command.java:96) ~[elasticsearch-5.0.1.jar:5.0.1]
	at org.elasticsearch.cli.Command.main(Command.java:62) ~[elasticsearch-5.0.1.jar:5.0.1]
	at org.elasticsearch.bootstrap.Elasticsearch.main(Elasticsearch.java:80) ~[elasticsearch-5.0.1.jar:5.0.1]
	at org.elasticsearch.bootstrap.Elasticsearch.main(Elasticsearch.java:73) ~[elasticsearch-5.0.1.jar:5.0.1]
Caused by: java.lang.IllegalArgumentException: No up-and-running site-local (private) addresses found, got [name:lo (lo), name:eth0 (eth0)]
	at org.elasticsearch.common.network.NetworkUtils.getSiteLocalAddresses(NetworkUtils.java:187) ~[elasticsearch-5.0.1.jar:5.0.1]
	at org.elasticsearch.common.network.NetworkService.resolveInternal(NetworkService.java:246) ~[elasticsearch-5.0.1.jar:5.0.1]
 	at org.elasticsearch.common.network.NetworkService.resolveInetAddresses(NetworkService.java:220) ~[elasticsearch-5.0.1.jar:5.0.1]
 	at org.elasticsearch.common.network.NetworkService.resolveBindHostAddresses(NetworkService.java:130) ~[elasticsearch-5.0.1.jar:5.0.1]
 	at org.elasticsearch.transport.TcpTransport.bindServer(TcpTransport.java:575) ~[elasticsearch-5.0.1.jar:5.0.1]
 	at org.elasticsearch.transport.netty4.Netty4Transport.doStart(Netty4Transport.java:182) ~[?:?]
 	at org.elasticsearch.common.component.AbstractLifecycleComponent.start(AbstractLifecycleComponent.java:68) ~[elasticsearch-5.0.1.jar:5.0.1]
 	at org.elasticsearch.transport.TransportService.doStart(TransportService.java:182) ~[elasticsearch-5.0.1.jar:5.0.1]
 	at org.elasticsearch.common.component.AbstractLifecycleComponent.start(AbstractLifecycleComponent.java:68) ~[elasticsearch-5.0.1.jar:5.0.1]
 	at org.elasticsearch.node.Node.start(Node.java:525) ~[elasticsearch-5.0.1.jar:5.0.1]
 	at org.elasticsearch.bootstrap.Bootstrap.start(Bootstrap.java:211) ~[elasticsearch-5.0.1.jar:5.0.1]
 	at org.elasticsearch.bootstrap.Bootstrap.init(Bootstrap.java:288) ~[elasticsearch-5.0.1.jar:5.0.1]
 	at org.elasticsearch.bootstrap.Elasticsearch.init(Elasticsearch.java:112) ~[elasticsearch-5.0.1.jar:5.0.1]
 	... 6 more
[2016-11-29T01:28:37,448][INFO ][o.e.n.Node               ] [kIEYQSE] stopping ...
[2016-11-29T01:28:37,451][INFO ][o.e.n.Node               ] [kIEYQSE] stopped
[2016-11-29T01:28:37,452][INFO ][o.e.n.Node               ] [kIEYQSE] closing ...
[2016-11-29T01:28:37,464][INFO ][o.e.n.Node               ] [kIEYQSE] closed
```

This is related to how the container binds to network ports (defaults to ``_local_``). It will need to match the actual node network interface name, which depends on what OS and infrastructure provider one uses. For instance, if the primary interface on the node is `p1p1` then that is the value that needs to be set for the `NETWORK_HOST` environment variable.
Please see [the documentation](https://github.com/pires/docker-elasticsearch#environment-variables) for reference of options.

In order to workaround this, set `NETWORK_HOST` environment variable in the pod descriptors as follows:
```yaml
- name: "NETWORK_HOST"
  value: "_eth0_" #_p1p1_ if interface name is p1p1, _ens4_ if interface name is ens4, and so on.
```

## Acknowledges

This repo is a customization of a [@pires' project](https://github.com/pires/kubernetes-elasticsearch-cluster) published in github. Thanks for this amazing job.

## License

This project is licensed under the MIT License - see the LICENSE.md file for details