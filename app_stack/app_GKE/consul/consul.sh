#!/bin/bash
set -v

echo "Installing Consul from Helm chart repo..."
git clone https://github.com/hashicorp/consul-helm.git
helm2 install --name=consul -f ./values.yaml ./consul-helm

sleep 10s

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  labels:
    addonmanager.kubernetes.io/mode: EnsureExists
  name: kube-dns
  namespace: kube-system
data:
  stubDomains: |
    {"consul": ["$(kubectl get svc consul-consul-dns -o jsonpath='{.spec.clusterIP}')"]}
EOF


sleep 20s
