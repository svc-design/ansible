#!/bin/bash

check_empty() {
  if [ -z "$1" ]; then
    echo "$2"
    exit 1
  fi
}

check_empty "$1" "Please provide harbor admin password"

echo Username: "admin"
echo Password: $(kubectl get secret --namespace harbor artifact-harbor-core-envvars -o jsonpath="{.data.HARBOR_ADMIN_PASSWORD}" | base64 -d)

export admin_passowrd=$1
curl -X PUT -u "admin:$admin_password" -H "Content-Type: application/json" -ki https://artifact.onwalk.ne/api/v2.0/configurations -d @/tmp/harbor-oidc-config.json
rm -f /tmp/harbor-oidc-config.json
