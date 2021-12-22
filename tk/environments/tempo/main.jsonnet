local agent = import 'agent.libsonnet';
local grafana = import 'grafana.libsonnet';
local prometheus = import 'prometheus.libsonnet';
local tempo = import 'tempo.libsonnet';

agent + grafana + prometheus + tempo + {

  local local_config = import '../../config.json',

  _images+:: {
    // images can be overridden here if desired
  },

  _config+:: {
    cluster: 'k3d-local-dev',
    namespace: 'default',

    grafana_cloud: local_config.grafana_cloud,

    // whether to send traces to local Tempo, this creates a feedback loop but
    // results in more and richer traces
    self_ingest: false,
  },
}
