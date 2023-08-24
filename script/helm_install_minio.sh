#!/bin/bash

PASSWORD=devops123
DEFAULT_BUCKETS="prometheus-metrics"

helm install minio \
--namespace minio --create-namespace \
--set auth.rootPassword=${PASSWORD} \
--set defaultBuckets="${DEFAULT_BUCKETS}" \
oci://registry-1.docker.io/bitnamicharts/minio