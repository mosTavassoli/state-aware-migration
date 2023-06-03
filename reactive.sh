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

tc_bool=0 #enable communication delay emulation
#kubectl apply -f ./pvc.yaml

kubectl label nodes worker-1 etcdlabel-
kubectl label nodes worker-2 etcdlabel-
kubectl label nodes worker-3 etcdlabel-
kubectl label nodes worker-4 etcdlabel-
kubectl label nodes worker-3 etcdlabel=etcdlabel

#for s in ${num_peers[@]}
#do
#kubectl apply -f ./prod-pvc.yaml
#kubectl apply -f ./cons-pvc.yaml
#if [ $tc_bool -eq 1 ]
#then
#  helm install my-etcd /home/crownlabs/etcd-k8s-experiment/etcd/etcd8s-net/ --set replicaCount=$s
#  sleep 300
#  /home/crownlabs/etcd-k8s-experiment/etcd/etcd8s-net/config-tc.sh #set delays
#  sleep 10
#else
#  helm install my-etcd /home/crownlabs/etcd-k8s-experiment/etcd/etcd8s  --set replicaCount=$s
#  sleep 80
#fi

for ((i=1; i<=20; i++))
do
	helm install my-etcd /home/crownlabs/etcd-k8s-experiment/etcd/etcd8s-net/ --set replicaCount=1
	sleep 80
	./producer.sh 1 1 worker-3
	sleep 5
	./consumer.sh worker-3
	./my-config-tc.sh

	sleep 55
	./get-logs-prod.sh before_prod$i
	./get-logs-cons.sh before_cons$i
	sleep25

	kubectl delete deployment ms-producer
	kubectl delete deployment ms-consumer
	kubectl label nodes worker-3 etcdlabel-
	kubectl label nodes worker-4 etcdlabel=etcdlabel
	helm delete my-etcd
	kubectl delete pvc --all
	sleep 20
	
	helm install my-etcd /home/crownlabs/etcd-k8s-experiment/etcd/etcd8s-net/ --set replicaCount=1
  sleep 80
  ./producer.sh 1 1 worker-4
	sleep 5
	./consumer.sh worker-4
	./my-config-tc.sh
	sleep 55
	./get-logs-prod.sh before_prod$i
	./get-logs-cons.sh before_cons$i
	sleep25

	#kubectl label nodes worker-1 etcdlabel=etcdlabel
	#kubectl label nodes worker-3 etcdlabel-
	#kubectl delete deployment ms-producer
	helm uninstall my-etcd
	kubectl delete pvc --all
	sleep 20
	kubectl delete deployment ms-producer
	kubectl delete deployment ms-consumer
	sleep 20
	kubectl label nodes worker-4 etcdlabel-
	kubectl label nodes worker-3 etcdlabel=etcdlabel
done

helm uninstall my-etcd

kubectl delete pvc --all
kubectl delete pv --all


