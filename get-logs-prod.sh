#!/bin/bash
set -x


# set the namespace
NAMESPACE=default

# set the operation parameter
OPERATION=$1


# get the name of the ms-producer pod
POD=$(kubectl get pods -n $NAMESPACE --field-selector=status.phase=Running -o jsonpath='{.items[*].metadata.name}' | awk '/ms-producer/{print $1}')


# check if the pod was found
if [ -z "$POD" ]; then
  echo "Error: could not find the ms-producer pod"
  exit 1
fi

# set the name of the log file
if echo "$OPERATION" | grep -q "before_prod"; then
  LOG_FILE="$OPERATION.csv"
elif echo "$OPERATION" | grep -q "after_prod"; then
  LOG_FILE="$OPERATION.csv"
else
  echo "Error: invalid operation parameter"
  exit 1
fi

# get the logs of the ms-producer pod
kubectl logs $POD -n $NAMESPACE -c ms-producer > "./logs/$LOG_FILE"
