#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ -z "${OKP_ACCESS_KEY:-}" ]; then
  read -rsp "Enter OKP_ACCESS_KEY: " OKP_ACCESS_KEY
  echo
fi

oc create namespace rhokp --dry-run=client -o yaml | oc apply -f -

oc -n rhokp create secret generic okp-access-secret \
  --from-literal=OKP_ACCESS_KEY="$OKP_ACCESS_KEY" \
  --dry-run=client -o yaml | oc apply -f -

oc apply -k "$SCRIPT_DIR/base/"

echo ""
echo "Waiting for pods..."
oc -n rhokp rollout status deployment/rhokp-solr --timeout=120s
oc -n rhokp rollout status deployment/rhokp-mcp --timeout=120s

echo ""
echo "=== Pods ==="
oc -n rhokp get pods
echo ""
echo "=== Route ==="
oc -n rhokp get route rhokp-mcp -o jsonpath='https://{.spec.host}{"\n"}'
