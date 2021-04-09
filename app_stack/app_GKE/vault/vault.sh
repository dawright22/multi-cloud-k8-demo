#!/bin/bash
set -v

# Clone the repo
helm2 install  --name=vault -f ./values.yaml ./vault-helm

sleep 30s




