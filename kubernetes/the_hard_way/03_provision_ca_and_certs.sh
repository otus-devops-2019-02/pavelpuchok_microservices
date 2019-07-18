#!/usr/bin/env sh

./create-ca.sh
./generate-admin-certificate.sh
./generate-kubelet-client-certificates.sh
./generate-controller-manager-cerificates.sh
./generate-kube-proxy-certificate.sh
./generate-scheduler-client-certificate.sh
./generate-k8s-api-server-certificate.sh
./generate-service-account-certificate.sh
./copy-certs.sh
