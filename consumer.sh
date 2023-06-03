#!/bin/bash

# generating the consumer YAML file

worker_node=$1

initConsumerYAML () {
cat << EOF > ./consumer.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ms-consumer
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ms-consumer
  template:
   metadata:
      labels:
        app: ms-consumer
   spec:
      containers:
      - name: ms-consumer
        image: mostafa2020/prod-cons:v1
        command:
          - sh
          - -c
          - |
            ./bin/consumer
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

initConsumerYAML
kubectl apply -f consumer.yaml
sleep 10

