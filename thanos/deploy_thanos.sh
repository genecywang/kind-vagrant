#!/bin/bash
NAMESPACE="thanos"
helm upgrade thanos oci://registry-1.docker.io/bitnamicharts/thanos -n ${NAMESPACE} -f receiver_mode_values.yaml --install