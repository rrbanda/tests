# RHOKP Deploy

One-shot deployment of **Red Hat Offline Knowledge Portal** (Solr + MCP server) on OpenShift.

Extracted from a live cluster — ready to copy-paste.

## Quick deploy (script)

```bash
OKP_ACCESS_KEY=<your_key> ./rhokp-deploy/deploy.sh
```

Or without the env var — it will prompt you:

```bash
./rhokp-deploy/deploy.sh
```

## Manual deploy (copy-paste)

```bash
# 1. Create namespace and secret
oc create namespace rhokp
oc -n rhokp create secret generic okp-access-secret \
  --from-literal=OKP_ACCESS_KEY=<your_access_key>

# 2. Deploy everything
oc apply -k rhokp-deploy/base/

# 3. Wait for rollout
oc -n rhokp rollout status deployment/rhokp-solr --timeout=120s
oc -n rhokp rollout status deployment/rhokp-mcp --timeout=120s

# 4. Verify
oc -n rhokp get pods
oc -n rhokp get route rhokp-mcp
```

## What gets created

| Resource | Name | Description |
|----------|------|-------------|
| Namespace | `rhokp` | Dedicated namespace |
| ServiceAccount | `rhokp-sa` | Shared service account |
| PVC | `okp-solr-data` | 10Gi persistent storage for Solr |
| Deployment | `rhokp-solr` | Solr search engine (port 8983) |
| Service | `rhokp-solr` | ClusterIP for Solr |
| Deployment | `rhokp-mcp` | MCP server (port 8000) |
| Service | `rhokp-mcp` | ClusterIP for MCP |
| Route | `rhokp-mcp` | Edge TLS route for MCP |

## Tear down

```bash
oc delete -k rhokp-deploy/base/
oc -n rhokp delete secret okp-access-secret
```
