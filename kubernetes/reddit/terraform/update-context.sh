#!/usr/bin/env sh
CLUSTER_NAME=reddit
CONFIG=kubeconfig

#export KUBECONFIG=${CONFIG}

gcloud container clusters get-credentials ${CLUSTER_NAME}
