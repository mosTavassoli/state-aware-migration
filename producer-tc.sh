#!/bin/bash

# generating the producer YAML file, with tc configuration

size=$1
key_size=$2
worker_node=$3

initProducerYAML () {
cat << EOF > ./producer.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ms-producer
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ms-producer
  template:
   metadata:
      labels:
        app: ms-producer
   spec:
      containers:
      - name: tc
        image: sixsq/iproute2
        command: ["sleep","infinity"]
        securityContext:
          capabilities:
            add:
            - NET_ADMIN
      - name: ms-producer
        image: mostafa2020/prod-cons:v26
        command:
          - sh
          - -c
          - |
            ./bin/producer $size $key_size
        volumeMounts:
        - name: kubectl-config-volume
          mountPath: /root/.kube
          readOnly: true
      volumes:
      - name: kubectl-config-volume
        secret:
          secretName: kubectl-config
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: kubernetes.io/hostname
                operator: In
                values:
                - $worker_node
EOF
}

initProducerYAML
kubectl apply -f producer.yaml
sleep 10


