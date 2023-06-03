#!/bin/bash

SECRET_NAME="kubectl-config"

if kubectl get secrets | grep -qw "$SECRET_NAME"; then
  echo "Secret $SECRET_NAME already exists"
else
  echo "Creating secret $SECRET_NAME"
  kubectl create secret generic "$SECRET_NAME" --from-file=config=/home/crownlabs/.kube/config
fi

set -x

key_size=1
size=(3)
key_size_int=$(echo $key_size | awk '{print int($1+0.5)}')
num_peers=(1)

kubectl label nodes worker-1 etcdlabel-
kubectl label nodes worker-2 etcdlabel-
kubectl label nodes worker-3 etcdlabel-
kubectl label nodes worker-4 etcdlabel-
kubectl label nodes worker-1 etcdlabel=etcdlabel
kubectl label nodes worker-2 etcdlabel=etcdlabel
kubectl label nodes worker-3 etcdlabel=etcdlabel
kubectl label nodes worker-4 etcdlabel=etcdlabel

helm install my-etcd /home/crownlabs/etcd-k8s-experiment/etcd/etcd8s-net/ --set replicaCount=4
sleep 100

for ((i=1; i<=20; i++))
do
	./mov-led-w3.sh
	sleep 5

	./producer.sh 1 1 worker-3
	./my-config-tc.sh
	sleep 40

	./get-logs-prod.sh before_$i
  sleep 25

	kubectl delete deployment ms-producer
	sleep 25

  ./mov-led-w4.sh
	sleep 5

	./producer.sh 1 1 worker-4
  ./my-config-tc.sh

	sleep 40
	./get-logs-prod.sh after_$i
	sleep 25

	kubectl delete deployment ms-producer
	sleep 20

done
#kubectl delete deployment ms-consumer
helm uninstall my-etcd


kubectl delete pvc --all
kubectl delete pv --all
