# homelab-k3s

This is the repository for the homelab-k3s environment. It contains the
configuration for the cluster and the software that runs on it.

## Access

Services are reachable over the tailnet. Only those listed under External are
also published to the internet.

### Internal (Tailscale)

| Service | URL |
| --- | --- |
| Home Assistant | https://homelab-0-home-assistant.tailb0b05.ts.net |
| openclaw | https://homelab-0-ollama.tailb0b05.ts.net |
| Pi-hole | https://pihole.tailb0b05.ts.net/admin |
| Obsidian LiveSync | https://obsidian.tailb0b05.ts.net |
| Longhorn | https://longhorn.tailb0b05.ts.net |
| Traefik dashboard | https://traefik.tailb0b05.ts.net |
| Dashboard | https://dashboard.tailb0b05.ts.net |
| VictoriaMetrics | https://metrics.tailb0b05.ts.net |
| Kubernetes API | https://homelab-k3s.tailb0b05.ts.net |

### External (internet)

| Service | URL |
| --- | --- |
| Home Assistant | https://hass.homelab.redback.dev |

### Kubernetes API

The Tailscale operator proxies the API server and authenticates callers by their
tailnet identity, so the kubeconfig carries no credentials. Generate it with:

```sh
tailscale configure kubeconfig homelab-k3s
```

which produces:

```yaml
apiVersion: v1
kind: Config
clusters:
  - name: homelab-k3s.tailb0b05.ts.net
    cluster:
      server: https://homelab-k3s.tailb0b05.ts.net
users:
  - name: tailscale-auth
    user:
      token: unused
contexts:
  - name: homelab-k3s.tailb0b05.ts.net
    context:
      cluster: homelab-k3s.tailb0b05.ts.net
      user: tailscale-auth
current-context: homelab-k3s.tailb0b05.ts.net
```

Access is granted by tailnet policy grants plus the RBAC bound to the
impersonated user, not by anything in this file.

## Secrets

Secrets are created by hand so their values never land in git.

### Proxmox exporter

`apps/monitoring/pve-exporter.yaml` reads a Proxmox API token for
`dashboard@pve!api`, a token on a user with the PVEAuditor role on `/`:

```sh
kubectl -n monitoring create secret generic pve-exporter --from-literal=token-value='<token secret>'
```

### Dashboard

`apps/dashboard` runs without a Secret, but each optional key turns on one data
source (see the homelab-dashboard README). Create or replace it with whichever
keys you have:

```sh
kubectl -n dashboard create secret generic dashboard \
  --from-literal=INGEST_TOKEN="$(openssl rand -hex 32)" \
  --from-literal=TS_CLIENT_ID='<oauth client id>' \
  --from-literal=TS_CLIENT_SECRET='<oauth client secret>' \
  --from-literal=GITHUB_TOKEN='<fine-grained token>'
```

The inventory is a ConfigMap built from `apps/dashboard/inventory.json`:

```sh
kubectl -n dashboard create configmap dashboard-inventory --from-file=inventory.json=apps/dashboard/inventory.json --dry-run=client -o yaml | kubectl apply -f -
```
