# er-frappe-docker

Template project for all frappe based platforms to copy, update and deploy with a standard template for the project and related configuration files.

## Pre-requisites
##### Understanding of basic concepts
Kubernetes provides logical wrappers over underlying implementations of majority of the resources like storage, containers etc. For updating configuration files in this project, basic understanding of these concepts is required. Important concepts used in this project configuration are -
* Storage Class
* Persistent Volume
* Persistent Volume Claim
* Pod
* Replicas

Fluentd is used as a sidecar container in every pod and is used to stream all log files from the application to ELK setup. This allows centralized monitoring of the application after deploying the same in a Kubernetes Cluster. 

##### Resources
* Working Kubernetes cluster - Currently Azure Kubernetes Service (AKS) and Local Minikube based implementations are supported
* Working kubernetes client - This is usually kubectl client that connects to the cluster remotely.
* Storage - Project needs pre-defined directories/file shares to be used for holding persistent data. This storage needs to be pre-defined and should be used while updating configuration files.
* Working setup of ELK with ElasticSearch service accessible from kubernetes cluster over TCP port
* MariaDB installation accessible from Kubernetes Cluster with root access.

##### Development Environment
Visual Studio Code with the Kubernetes Extension is recommended for development using Kubernetes - local or remote (AKS).

## Setup and Deployment
### Step 1 - Setting up Pre-requisites
The application expects the cluster, storage and elk to be already setup. Following links provide details of each of these components and can be used to setup these resources.
#### Setting up a Kubernetes Cluster
A Development Kubernetes cluster can be setup locally on developer machines using 'minikube'. More details on how this can be achieved, are available [here](https://kubernetes.io/docs/setup/minikube/).

A Test/Staging/Prod cluster will typically be hosted using a cloud provider like Azure. Currently, Azure Kubernetes Cluster (AKS) related files have been configured with necessary constructs, and can be updated and used. However, the AKS cluster needs to be created using steps described [here](https://docs.microsoft.com/en-us/azure/aks/tutorial-kubernetes-deploy-cluster).

*Note that creation of service principal, as mentioned in the above article, is optional and this __should not__ be created* 

#### Storage Provisioning
* __Local Cluster using Minikube__ - For running the cluster locally, only the option of 'hostPath' type of storage / persistent volume is available. For setting this up, it is suggested to create a new directory on the developer machine and use the same in configuration files under 'k8s/local' folder. The absolute path of this directory needs to be provided in the \*-pv-\*.yaml files.

* __AKS Cluster__ - Azure provides a concept of Azure File Share that is used for dynamically provisioning the storage requests through AKS Persistent Volume Claims. Hence, as part of setup of a frappe based application, an Azure File Share needs to be created under a storage account. It is advisable to create a separate storage account per platform to ensure that data is seggregated across platforms. The Azure file share details - including the name of the storage account, key used to access the account, need to be configured as part of the configuration files. The access key and the name of the account need to be Base64 encoded and provided in the `*02-er-frappe-aks-share-secret.yaml*` file. Following command can be used to encode the values on Ubuntu systems -

    `echo -n <oroginal value> | base64 -w 0`

* __ELK Setup__ - For deployments on AKS, a shared ELK setup should be used. For local installations, following articles can help for setting up the same.

    [ELK on Ubuntu 18.04](https://www.digitalocean.com/community/tutorials/how-to-install-elasticsearch-logstash-and-kibana-elastic-stack-on-ubuntu-18-04)
    
    [ELK on Ubuntu 16.04](https://www.digitalocean.com/community/tutorials/how-to-install-elasticsearch-logstash-and-kibana-elastic-stack-on-ubuntu-16-04)

    [ELK on Windows - Option 1](https://dzone.com/articles/installing-the-elk-stack-on-windows)
    
    [ELK on Windows - Option 2](http://robwillis.info/2016/05/installing-elasticsearch-logstash-and-kibana-elk-on-windows-server-2012-r2/)
    
* __MariaDB Instance__ - A working instance of mariadb is required for hosting any frappe application. This instance can be in turn hosted on Kubernetes or as a standalone instance on a dedicated VM. In either case, this instance should be accessible, with root access, over TCP port 3306 (if using default configuration) from kubernetes cluster.

### Step 2 - Configuration Files
Configuration files for the cluster based deployment are created in a specific directory structure.

1. `fluentd/k8s` - Directory that holds the configurations for `fluentd` sidecar container. These files set up the required resources for ELK communication.
    * `00-er-frappe-fluentd-configmaps.yaml` - Contains configuration file for `fluentd`. Refer to [`fuentd configuration file syntax documentation`](https://docs.fluentd.org/v1.0/articles/config-file) to decide contents of `fluent.conf` configuration file.
    
    * `01-er-frappe-elasticsearch-service.yaml` - Contains configuration to expose the underlying ElasticSearch service as a Kubernetes Service. Update this file to point it to correct TargetPort as configured in the Endpoint (see below). For local deployments, this will be a local ElasticSearch installation, while for AKS, it will point to an external centrally hosted ElasticSearch service.

        ***Note for local deployments** - The Minikube installation uses a VM running on the developer machine. If the ElasticSearch service is running on the host machine, it will not be availalbe on the VM that runs the kubernetes cluster. To make this service available, SSH tunnel can be setup between host and VM using following command. Multiple -R flags can be provided to create multiple tunnels.*
        
        `ssh -i $(minikube ssh-key) docker@$(minikube ip) -R <vm-port>:localhost:<host-port>`
        
        Example - `ssh -i $(minikube ssh-key) docker@$(minikube ip) -R 9292:localhost:9200` - this command exposes ElasticSearch service listening on 9200 TCP port on host machine, as port 9292 on VM running Kubernetes Cluster.
       
    *  `fluentd/k8s/local` - Contains files specific to local setup of ELK and Kubernetes Cluster using Minikube
        *  `02-er-frappe-elasticsearch-endpoint.yaml` - This file provides the endpoint to which the above service should connect to. For local installation, this should point to the host machine IP on the host-only network created by the Minikube VM.
        
    *  `fluentd/k8s/aks` - Contains files specific to a central setup of ELK and Kubernetes Cluster using AKS
        * `02-er-frappe-elasticsearch-endpoint.yaml` - This file provides the endpoint to which the above service should connect to on AKS cluster. This would typically point to the hostname or IP on which ElasticSearch service is hosted and corresponding TCP port. This host and port must be accessible from the kubernetes cluster for this integration to work.

2. `k8s` - Directory that holds the configurations for Kubernetes resources required for frappe application. This creates storage classes, persistent volumes, persistent volume claims and deployments required.
    * `00-er-frappe-mariadb-service.yaml` - Defines a `mariadb` service that wraps the underlying mariadb instance and exposes it as a standard service with pre-defined name on Kubernetes Cluster.
    * `01-er-frappe-mariadb-endpoint.yaml` - Defines the endpoint to which the mariadb service connects to. This is the physical address of the destination mariadb instance (IP:port).
    * `aks/02-er-frappe-aks-share-secret.yaml` - This is AKS-only configuration and defines the access keys required to access the file share created on Azure.
    * `aks/03-er-frappe-aks-sc.yaml` - Defines the storage class to be created on AKS. This connects the storage account on Azure to with the correspnding storage class. Any PVCs that request this storage class, will then be mapped to corresponding storage account.
    * `local/03-er-frappe-aks-sc.yaml` - Defines the storage class to be created on local cluster. This creates a standard storage class with hostPath provisioner from Minikube. Any PVCs that request this storage class, will then be mapped to the corresponding host path directory configured in the PersistentVolume created for this storage class. Note that if the directory is created on the host machine, it needs to be mounted on the Minikube VM for it to be accessible to local Kubernetes Cluster. For more details on how to achieve this, please refer to [Minikube documentation](https://github.com/kubernetes/minikube/blob/master/docs/host_folder_mount.md). Alternatively, folders can be mounted while starting minikube. For more details, check outout of `minikube start --help`.
    * `aks/04-er-frappe-aks-pv-sites.yaml` - Defines the persistent volume that connects a storage class (created above) with an existing file share. This is then used to fulfill all persistent volume claims by the application.
    * `local/04-er-frappe-aks-pv-sites.yaml` - Defines the exact location of the host path (absolute path to the directory on VM) and maps the same to the corresponding storage class (created above). Any persistent volume claims from the application are then provisioned using this folder.
    * `05-er-frappe-aks-pvc.yaml` - Creates a persistent volume claim that will be bound to the underlying storage (aks or local) using the defined storage class and persistent volume that are referenced in this file.
    * `06-er-frappe-frappe-secrets.yaml` - Defines the values to be used for database host (should be same as the mariadb service name created above), DB name to be created/used, root password for connecting to the DB and administrator password for the site created for the frappe application.
    * `07-er-frappe-redis-configmaps.yaml` - Creates the configuration to be used by different redis containers started as part of Frappe pods.
    * `08-er-frappe-redisq-deployment.yaml` - Creates a shared deployment for redis-queue instance. This is created as an independent service that is shared amongst multiple replicas of the same frappe application. This can also be shared amongst multiple application, provided the applications support this. This deployment uses the `redis-queue.conf` created as part of above config map.
    * `09-er-frappe-redis-cache-service.yaml` - Creates a logical service wrapper over all redis-cache instances started along with the frappe application. All instances are load-balanced through this service.
    * `10-er-frappe-redis-queue-service.yaml` - Creates a logical service wrapper over the shared redis-queue deployment created above. All replicas of the redis-queue are load-balanced through this service.
    * `11-er-frappe-redis-socketio-service.yaml` - Creates a logical service wrapper over all redis-socketio instances started along with the frappe application. All instances are load-balanced through this service.
    * `12-er-frappe-deployment.yaml` - Creates the deployment of the application that combines total of 4 containers. Main application container, named er-frappe, refers to the image to be used for the application. By default, the `sites` folder under the bench instance folder created, is mapped to an external volume through persistent volume claim (created above). Thus, sites contents will be persisted across container restarts. The deployment ties together redis-cache, redis-socketio and fluentd containers along with the application container to provide necessary services for functioning of the frappe based application.
    * `13-er-frappe-frappe-service.yaml` - Creates a logical wrapper of type *LoadBalancer* that exposes a load-balanced end-point for the deployed application for the external world to consume. The port defined in this file is the TCP port on which the application becomes available. Typically, there will be a separate NGinx layer on top of this, which will act as a reverse proxy. However, the application will be directly available on the port mentioned in this file.
