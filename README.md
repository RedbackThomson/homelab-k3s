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
| Traefik dashboard | https://traefik.tailb0b05.ts.net |
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
