#!/bin/bash

set -x

USER="crownlabs"
SSHPASS="crownlabs"

WK1="<IP>"
WK2="172.16.203.37"
WK3="<IP>"
WK4="172.16.133.251"
WK5="<IP>"

sshpass -p $SSHPASS ssh -t $USER@$WK2 "sudo tc qdisc add dev enp1s0 root netem latency 20ms"
sshpass -p $SSHPASS ssh -t $USER@$WK4 "sudo tc qdisc add dev enp1s0 root netem latency 5ms"
