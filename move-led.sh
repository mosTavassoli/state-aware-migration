#!/bin/bash

leader_ip=$(kubectl get pods --field-selector metadata.name=my-etcd-0 -o json | egrep '\"podIP\"' | grep -E -o '\"([0-9]{1,3}[\\.]){3}[0-9]{1,3}\"' | sed 's/"//g')
echo $leader_ip
dst_ip=$(kubectl get pods --field-selector metadata.name=my-etcd-1 -o json | egrep '\"podIP\"' | grep -E -o '\"([0-9]{1,3}[\\.]){3}[0-9]{1,3}\"' | sed 's/"//g')
echo $dst_ip
src_member_id=$(etcdctl --endpoints=$leader_ip:2379 endpoint status | awk '{print $2}' | sed -e $'s/,//g')
echo $src_member_id
dst_member_id=$(etcdctl --endpoints=$dst_ip:2379 endpoint status | awk '{print $2}' | sed -e $'s/,//g')
echo $dst_member_id
output=$(etcdctl --endpoints=$leader_ip:2379 move-leader $dst_member_id)
echo $output

#std::string expected_output = "Leadership transferred from " + src_member_id + " to " + dst_member_id + "\n";
