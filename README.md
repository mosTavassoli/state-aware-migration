# State-aware migration for edge mobile application

There are three main script files to get the result.

1. **centralized.sh**: code for Centralized approach
2. **reactive.sh**: code for Reactive approach
3. **proactive.sh**: code for Proactive approach

Each file contains some simple configuration and creates a specific manifest for testing purposes.

There is a **Dockerfile** that is going to create the Docker image of two testing CPP applications, like producer.cpp and consumer.cpp, and related libraries. Then, the created image is used as the container in the manifest in producer.sh, and in consumer.sh. These two files are used to deploy our testing application.

The files **cons.cpp, prod.cpp, etcdAPIs.cpp, and etcdAPIs.hpp** are related to testing applications used to experiment and generate the result.

## Running

First, create the image by running the Docekrfile. Then use the created image inside the consumer.sh and producer.sh to generate a container.

```
spec:
    containers:
    - name: ms-consumer
      image: <image>
```

To run the etcd instance in one specific worker, added the value for nodeSelector for values.yaml in etcd.bitnami.

```
## @param nodeSelector [object] Node labels for pod assignment
## Ref: https://kubernetes.io/docs/user-guide/node-selection/
##
nodeSelector:
  etcdlabel : etcdlabel
```

Finally, you can run the code for related testing applications, centralized.sh, reactive.sh, or proactive.sh. Just before, inside these files, replace the address of the helm configuration to the proper place in your machine.

```
helm install my-etcd <proper-address> --set replicaCount=1
```
