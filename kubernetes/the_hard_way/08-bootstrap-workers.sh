#!/usr/bin/env sh

for instance in worker-0 worker-1 worker-2; do
  gcloud compute scp bootstrap-worker.sh ${instance}:~/
  gcloud compute ssh ${instance} --command "chmod +x bootstrap-worker.sh; ./bootstrap-worker.sh"
done

gcloud compute ssh controller-0 \
  --command "kubectl get nodes --kubeconfig admin.kubeconfig"

