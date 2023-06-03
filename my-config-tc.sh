#!/bin/bash

POD_PRO=$(kubectl get pods | grep ms-producer | awk '{print $1}')
POD_CONS=$(kubectl get pods | grep ms-consumer | awk '{print $1}')

kubectl exec my-etcd-0 -c tc -- tc qdisc add dev eth0 root netem delay 1ms
kubectl exec my-etcd-1 -c tc -- tc qdisc add dev eth0 root netem delay 1ms
kubectl exec my-etcd-2 -c tc -- tc qdisc add dev eth0 root netem delay 1ms
kubectl exec my-etcd-3 -c tc -- tc qdisc add dev eth0 root netem delay 1ms

kubectl exec $POD_PRO -c tc -- tc qdisc add dev eth0 root netem delay 1ms
kubectl exec $POD_CONS -c tc -- tc qdisc add dev eth0 root netem delay 1ms

