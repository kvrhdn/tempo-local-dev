# tempo-local-dev

A local development setup to work on [Grafana Tempo](https://github.com/grafana/tempo).

## Setup

Create `config.json` based upon `config-template.json` and fill in the fields.

## Dashboards

[`dashboards`](./dashboards/) will provision all dashboards from the Grafana Agent and Tempo mixins.

Be sure to configure `config.json` and run:

```shell
make provision-dashboards
```

## Tanka & Tilt

[`tk`](./tk/) and [`Tiltfile`](Tiltfile) will set up a local Kubernetes cluster with:

- Grafana Tempo in microservices mode
- Prometheus
- Grafana
- Grafana Agent to ship metrics, log and traces to Grafana Cloud

The Kubernetes cluster is run inside Docker using [k3d](https://k3d.io/v5.2.2/). [Tilt](https://tilt.dev) will automatically provision Kubernetes resources and reload Tempo pods when the code changes.

```shell
make create-cluster
tilt up
```

Teardown the cluster:

```shell
make destroy-cluster
```
