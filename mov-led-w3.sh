#!/bin/bash

# this script is going to move the leader to worker 3

# This script allows to identify which instance of the etcd cluster has been elected as leader of the Raft consensus protocol
podIPs=$(kubectl get pods --selector app.kubernetes.io/instance=my-etcd -o json | egrep '\"podIP\"' | grep -E -o "([0-9]{1,3}[\\.]){3}[0-9]{1,3}")

# Get the IP of the etcd instance running on worker-3
worker3_etcd_ip=$(kubectl get pods --field-selector spec.nodeName=worker-3 -l app.kubernetes.io/instance=my-etcd -o jsonpath='{.items[0].status.podIP}')

for ip in ${podIPs[@]}
do
    member_id=$(etcdctl --endpoints=$ip:2379 endpoint status -w fields | grep MemberID | grep -Eo '[0-9]{1,30}')
    leader_id=$(etcdctl --endpoints=$ip:2379 endpoint status -w fields | grep Leader | grep -Eo '[0-9]{1,30}')

    if [ $member_id == $leader_id ]
    then
        echo "Leader is on $ip"
        # Check if the leader is running on the etcd instance on worker-3
        if [[ $ip == $worker3_etcd_ip ]]; then
            echo "Leader is running on the etcd instance on worker-3, nothing to do."
        else
            echo "Leader is not running on the etcd instance on worker-3."
            dst_ip=$worker3_etcd_ip
            dst_member_id=$(etcdctl --endpoints=$dst_ip:2379 endpoint status | awk '{print $2}' | sed -e $'s/,//g')
            echo "Destination IP: $dst_ip"
            echo "Destination Member ID: $dst_member_id"
            output=$(etcdctl --endpoints=$ip:2379 move-leader $dst_member_id)
            echo "Move leader output: $output"
        fi
    fi
done
