#!/bin/bash

# SECRET_NAME="kubectl-config"

# if kubectl get secrets | grep -qw "$SECRET_NAME"; then
#   echo "Secret $SECRET_NAME already exists"
# else
#   echo "Creating secret $SECRET_NAME"
#   kubectl create secret generic "$SECRET_NAME" --from-file=config=/home/crownlabs/.kube/config
# fi

# set -x

key_size=1
size=(3)
key_size_int=$(echo $key_size | awk '{print int($1+0.5)}')
num_peers=(1)

tc_bool=0 #enable communication delay emulation

for s in ${num_peers[@]}
do
if [ $tc_bool -eq 1 ]
then
  helm install my-etcd /home/crownlabs/etcd-k8s-experiment/etcd/etcd8s-net/ --set replicaCount=$s
  sleep 300
  /home/crownlabs/etcd-k8s-experiment/etcd/etcd8s-net/config-tc.sh #set delays
  sleep 10
else
  helm install my-etcd /home/crownlabs/etcd-k8s-experiment/etcd/etcd8s  --set replicaCount=$s
  sleep 80
fi

for ((i=1; i<=20; i++))
do
  ./producer.sh 1 $key_size worker-1
	sleep 5
	./consumer.sh worker-1
	sleep 35
	./get-logs-prod.sh before_prod$i
	./get-logs-cons.sh before_cons$i
	sleep25

	kubectl delete deployment ms-producer
	kubectl delete deployment ms-consumer
	./producer.sh 1 1 worker-2
	sleep 5
	./consumer.sh worker-2
	sleep 35

	./get-logs-prod.sh after_prod$i
	./get-logs-cons.sh after_cons$i
	sleep 10

	kubectl delete deployment ms-producer
	kubectl delete deployment ms-consumer
done
#kubectl delete deployment ms-consumer
helm uninstall my-etcd


kubectl delete pvc --all
kubectl delete pv --all

done
