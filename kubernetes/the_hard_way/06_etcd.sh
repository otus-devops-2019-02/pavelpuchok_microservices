#!/usr/bin/env sh

for instance in controller-0 controller-1 controller-2; do
  gcloud compute scp install-etcd.sh ${instance}:~/
  gcloud compute ssh ${instance} --command "chmod +x install-etcd.sh; ./install-etcd.sh"
done

