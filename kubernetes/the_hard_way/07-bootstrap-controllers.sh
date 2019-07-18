#!/usr/bin/env sh

for instance in controller-0 controller-1 controller-2; do
  gcloud compute scp bootstrap-controller.sh ${instance}:~/
  gcloud compute ssh ${instance} --command "chmod +x bootstrap-controller.sh; ./bootstrap-controller.sh"
done

gcloud compute scp rbac.sh controller-0:~/
gcloud compute ssh controller-0 --command "chmod +x rbac.sh; ./rbac.sh"

./lb.sh
